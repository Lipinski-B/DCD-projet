import json
import pandas as pd
import sys
from sklearn.pipeline import Pipeline
import pandas as pd
import numpy as np
import scipy
from scipy import sparse
from scipy.sparse import vstack
from sklearn.cluster import KMeans
import matplotlib.pyplot as plt
import pickle

def vectorizer2(fileUniqueSongs, filePlaylists):
    listSongs = pd.read_csv(fileUniqueSongs, header = None)
    songs = listSongs.values
    with open(filePlaylists, 'r') as f:
        jsonDict = json.load(f)
    dicSongs = {}
    for track in jsonDict['items']:
        if track['track']['uri'] in dicSongs:
            dicSongs[track['track']['uri']]+=1
        else:
            dicSongs[track['track']['uri']]=1
    vect = []
    for song in songs:
        if song[0] in dicSongs:
            vect.append(1)
        else:
            vect.append(0)
            
    return vect
    
if __name__=="__main__":
	# to change the number of recomandation you can pass a 2nd argument
	if len(sys.argv) == 3:
		topN = int(sys.argv[2])
	else:
		#Default is 10
		topN = 10
		
	file = open('Data/names.txt','r')
	name = file.readlines()

	#Vectorizing the input playlist
	inputP = vectorizer2('Data/names.txt', sys.argv[1])
	inputP = np.array(inputP).reshape(-1, 1).transpose()
	
	#TODO
	#Loading the model
	pipe = pickle.load(open("Kmeans.plk", "rb"))
	
	#Identify input cluster
	pred = pipe.predict(inputP)
	
	#Get the playlists from the same cluster
	sparse_matrix = scipy.sparse.load_npz('Data/mat.npz')
	
	playlists = pipe.predict(sparse_matrix)
	playlists = pd.DataFrame(playlists)
	playlists = playlists.mask(playlists != pred).replace(float(pred),1).dropna()
	
	matrix_final = sparse_matrix[playlists.index.values,:]
	
	#Formating the matrix to make column sum
	matrix_final = scipy.sparse.csr_matrix.sum(matrix_final, axis=0)
	recomandation = pd.DataFrame(matrix_final, columns=name)
	recomandation.index = ["sum"]
	
	recomandation = recomandation.sort_values(by=["sum"], ascending=False, axis=1)
	
	#Filtering the playlist
	a=inputP.tolist()
	b=recomandation.columns.tolist()

	filtered = [i for i in b if not i in a]
	filtered = pd.DataFrame(filtered)
	
	#Writing the Output file (link to the suggested songs)
	with open("suggestion.txt", "w") as output:
		for i in range(topN):
			uri = filtered.iloc[i].values[0].split(":")[-1].strip()
			output.write("https://open.spotify.com/track/{}\n".format(uri))
			
		
	
