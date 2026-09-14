import numpy as np
import sdeint
import yaml
import os, sys
import scipy.sparse as sp

def load_yaml_config(file_path):
    try:
        with open(file_path, 'r') as file:
            config = yaml.safe_load(file)
        return config
    except FileNotFoundError:
        print(f"Error: File not found at {file_path}")
        return None
    except yaml.YAMLError as exc:
        print(f"Error reading YAML file: {exc}")
        return None

config = load_yaml_config(sys.argv[1])
print(config)
#Fixed parameters
dt = config.get('dt',0.01)
Nspecies = config.get('Nspecies',50)
Nextra = config.get('Nextra',20)
r = config.get('r',1.0) 
mu = config.get('mu',0.0)
sigma = config.get('sigma',0.1)
Nreal = config.get('Nreal',1)
Nprint = config.get('Nprint',1)
Nsteps = config.get('Nsteps',1)
sigma_env2 = config.get('sigma_env2',0.1)
muG = config.get('mu_extra',1.e-3)    # Desired mean for the extra species
sigma2G = config.get('sigma2_extra',1.e-4) # Desired variance for the extra species
newpath = config.get('path','simulations/output') #Directory
x0 = config.get('x0', np.full(Nspecies, 1./Nspecies)) #Initial condition
# Compute shape (k) and scale (theta)
kG = muG**2 / sigma2G
thetaG = sigma2G / muG

#Build matrices
Adiag = np.diag(np.full(Nspecies,-1.0))
A_nodiag = np.full((Nspecies,Nspecies),mu/Nspecies)
A_nodiag -= np.diag(np.full(Nspecies,mu/Nspecies))
Amatrix = Adiag+A_nodiag
print(Amatrix,sigma)

S_nodiag = np.full((Nspecies,Nspecies),sigma/np.sqrt(Nspecies))
S_nodiag -= np.diag(np.full(Nspecies,sigma/np.sqrt(Nspecies)))

list_t = [np.arange(i * dt*Nprint, (i + 1) * dt*Nprint+1.e-6, dt) for i in range(Nsteps)]

if not os.path.exists(newpath):
    os.makedirs(newpath)
    
for T in Temps:
    print(T)
    #Growth rate matrix
    rmatrix = np.diag(np.full(Nspecies,r-T))
    #Interactions (Drift term)
    def f(x, t):
        #x = x.reshape(Nspecies)
        dx = np.zeros(Nspecies)
        for i in range(Nspecies):
            dx[i] = x[i] * (r-T+np.dot(Amatrix[i, :], x))
        return dx
    # Diffusion function G(x, t)
    def G(x,t):
        #x = x.reshape(Nspecies)
        G_matrix = np.zeros((Nspecies, Nspecies))
        # Diagonal noise terms (scaled by sqrt(2 * T) * x_i)
        for i in range(Nspecies):
            G_matrix[i, i] = 2 * T * x[i]*x[i]
        # Off-diagonal noise terms (scaled by sigma * x_i * x_j)
        for i in range(Nspecies):
            for j in range(Nspecies):
                if i != j:
                    G_matrix[i, i] += ((sigma/np.sqrt(Nspecies)) * x[i] * x[j])**2
            # Convert to sparse matrix to save memory
            G_matrix[i,i] = np.sqrt(G_matrix[i,i])
        return G_matrix
    #S_diag = np.diag(np.full(Nspecies,np.sqrt(2.0*T)))
    for i in range(Nreal):
        to_print_list = []
        samples_0 = np.random.gamma(shape=kG, scale=thetaG, size=Nextra)
        to_print = np.concatenate([[0.],[x0.T[i] for i in range(Nspecies)]]).T
        to_print_list.append(np.concatenate([to_print,samples_0]))
        xt = sdeint.stratint(f, G, x0, list_t[0])
        # Generate samples for extra species: shape Nextra
        samples_extra = np.random.gamma(shape=kG, scale=thetaG, size=Nextra)
        to_print = np.concatenate([[list_t[0]],[xt.T[i] for i in range(Nspecies)]]).T
        to_print_list.append(np.concatenate([to_print[-1],samples_extra]))
        cont = 0
        for t in list_t[1:]:
            #Integration
            cont+=1
            print(cont)
            xt = sdeint.stratint(f, G, xt[-1], t)
            # Generate samples for extra species: shape (Nextra, mG)
            mG = len(t)
            samples_extra = np.random.gamma(shape=kG, scale=thetaG, size=Nextra)
            to_print = np.concatenate([[t],[xt.T[i] for i in range(Nspecies)]]).T
            to_print_list.append(np.concatenate([to_print[-1],samples_extra]))
        to_print_list = np.array(to_print_list)
        np.savetxt(newpath+'/Sim_'+int_type+'_{ii:d}_Temp_{TT:.2f}_mu_{mu:.2f}_sigma_{sigma:.2f}_N_{Nspecies:d}_extra_{Nextra:d}.txt.gz'.format(ii=i,TT=T,Nspecies=Nspecies,mu=mu,sigma=sigma,Nextra=Nextra),to_print_list)

