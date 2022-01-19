import pandas as pd
import numpy as np
import shutil, random, os


configfile: "config/config.yaml"

alleles = pd.read_csv(config["hla"], sep ="\t")

def random_percentage(s,n): #x: seed, n: number of samples in the end
    np.random.seed(s)
    ran_num = np.random.random(n)
    ran_num /= ran_num.sum()
    ran_num = ran_num.tolist()
    return ran_num

def create_mixed_samples(n,k): #n: number of samples in the end, k: number of fractions
    i = 0
    df = pd.DataFrame(columns=['hla'])
    while i < n:
        i += 1
        sel = alleles.sample(k, random_state=i)
        sel['num'] = random_percentage(i,k)
        sel['num_reads'] = sel['num']*2000 #assume the mixture will have 2000 reads
        sel['sample_name'] = "SampleM" + str(i)

        df = pd.concat([df,sel])
        df['num_reads'] = df['num_reads'].astype(int).astype('str')
    del df['num'] 
    return df

def create_pure_samples(n):
    i = 0
    df = pd.DataFrame(columns=['hla'])
    while i < n:
        i += 1
        sel = alleles.sample(1, random_state=i)
        sel['num_reads'] = 2000 #assume the mixture will have 2000 reads
        sel['sample_name'] = "SampleP" + str(i)

        df = pd.concat([df,sel])
        df['num_reads'] = df['num_reads'].astype(int).astype('str')
    return df

df = pd.concat([create_mixed_samples(2,4), create_pure_samples(2)])
