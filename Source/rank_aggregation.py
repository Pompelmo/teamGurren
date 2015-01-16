# from numpy import matrix


__version__ = '0.2.1'

import os
import sys
import csv
import argparse as ap

#--------------------------------- rpy2 imports
import rpy2.robjects as robjects
from rpy2.robjects.packages import importr





class Rank_aggregator:
	"""Rank_aggregator object"""

	#---------------------------------- inizialization of class R environment and loading of R functions

	silent = open(os.devnull, 'w') #start silencing stdout (becouse of R prints something)
	normal = sys.stdout
	sys.stdout =silent

	base= importr("base")
	stats = importr("stats")
	robjects.r('source("Funzioni_2.0.R")')
	R = robjects.globalenv
	#----------------------------------- R function for bba_par
	mean = base.mean
	minimum = base.min
	median = stats.median
	mc4 = "MC4"

	sys.stdout = normal #finish silencing stdout
	silent.close()
 
	#--------------------------------------- costructor
	# def __init__(self, data=None,col_metadata=0,data_header=False,classes=None,classes_header=False,k_max=None):
	def __init__(self, data=None,col_metadata=0,data_header=False,k_max=None):


		#----------------------------------- creation of class variables
		self.data = None #data as a list of lists
		self.Rdata = None # data as a dataframe
		self.col_metadata = 0
		self.k_max = None

		self.last_rank = None # las rank computed, as list of tuples

		#------------------------------------ inizialization of data
		if data != None :
			self.set_dataframe_rank(data,data_header)


		#------------------------------------ inizialization of col_metadata
		if col_metadata != None :
			self.set_col_metadata(col_metadata)


		#----------------------------------- inizialization of kmax		
		if k_max != None :
			self.set_k_max(k_max)


	#---------------------------------static methods

	@staticmethod
	def dataframe_from_csv(data_path,row_header=False) :
		return robjects.vectors.DataFrame.from_csvfile(data_path,header=row_header)

	@staticmethod
	def dataframe_from_list(mat) :
		#----------------------------- check if is iterable
		try:
		    i = iter(mat)
		except TypeError, te:
		    raise TypeError('object passed is not iterable')
			
		
		#-------------------------------- check the len of the column of mat, if they aren't all the same add empty strings at the bottom of the shorters
		l = len(mat[0])
		flag = False
		for i in mat :
			if len(i) != l :
				l = max(l,len(i))
				flag = True
		if flag :
			for i in mat :
				if len(i) != l:
					i.extend([""]*(l-len(i)))

		#---------------------------------creating R data frame

		df = Rank_aggregator.base.data_frame(Rank_aggregator.Rmatrix(mat))


		return df

	@staticmethod
	def list_from_dataframe(data_frame) :
		if type(data_frame) != robjects.vectors.DataFrame :
			raise ValueError("object passed is not a rpy2.robjects.vectors.DataFrame")

		l= []
		for i in range(0,data_frame.ncol) :
			l.append(list(Rank_aggregator.base.as_vector(data_frame[i])))

		return [tuple(i) for i in zip(*l)] #return the transposed matrix

	@staticmethod
	def Rmatrix(data) : 
	    """create a R matrix  from the matrix passed"""

	    # base = importr('base')
	    mat_list = []
	    for r in data :
	        mat_list += r

	    R_matrix = Rank_aggregator.base.matrix(robjects.vectors.StrVector(mat_list),nrow=len(data),byrow=True)

	    return R_matrix

	#-----------------------------------get/set methods

	def get_dataframe_rank(self,R=False) :

		if R :
			if self.Rdata == None :
				raise ValueError("no rank data in this istance of Rank_aggregator")
			return self.Rdata
		else :
			if self.data == None :
				raise ValueError("no rank data in this istance of Rank_aggregator")
			return self.data


	def set_dataframe_rank(self,data,data_header=False) :
		if type(data) == str :
			if not os.path.exists(data) :
				raise IOError("'"+data+"' is not a readable file")

			self.Rdata = Rank_aggregator.dataframe_from_csv(data,row_header=data_header)
			self.data = list(csv.reader(open(data,"r"))) 
		
		# elif type(data) == robjects.vectors.DataFrame :
		# 	self.Rdata = data

		elif hasattr(data, '__iter__'):
			self.Rdata = Rank_aggregator.dataframe_from_list(data)
			self.data = list(data)

		else :
			raise TypeError(type(data)+" data type not supported")


		


	def get_k_max(self) :
		if self.k_max == None :
			raise ValueError("no k_max specified in this istance of Rank_aggregator")
		return self.k_max

	def set_k_max(self,k_max) :

		
		try:
			k =int(k_max)

		except ValueError:
			raise ValueError("k_max must be an object convertible to an integer")

		else :
			if k <= 0:
				raise ValueError("k_max must be >0")
			self.k_max = int(k_max)
			

	def get_col_metadata(self) :
		return self.col_metadata	

	def set_col_metadata(self,col) :
		try:
			k =int(col)

		except ValueError:
			raise ValueError("col_metadata must be an object convertible to an integer")	

		else :
			if k < 0:
				raise ValueError("col_metadata must be >=0")
			self.col_metadata = int(col)
			
	def get_aggregated_rank(self) :
		if self.last_rank == None :
			raise ValueError("no aggregated rank in this istance of Rank_aggregator")
		# if type(self.last_rank) !=list :
		# 	return self.list_from_dataframe(self.last_rank)
		else :
			return self.last_rank

	# def set_aggregated_rank(self,rank) :

	# 	if type(rank) == str :
	# 		if not os.path.exists(rank) :
	# 			raise IOError("'"+rank+"' is not a readable file")

	# 		self.last_rank = Rank_aggregator.dataframe_from_csv(rank)
		
	# 	elif type(rank) == robjects.vectors.DataFrame :
	# 		self.last_rank = rank

	# 	elif hasattr(rank, '__iter__'):
	# 		self.last_rank = Rank_aggregator.dataframe_from_list(rank)

	# 	else :
	# 		raise TypeError(type(rank)+" data type not supported")


	#------------------------------------------------ ranking functions

	def bba_par_ranker(self,N_ite=1,estimator=mean) :

		if estimator not in set([Rank_aggregator.mean,Rank_aggregator.minimum,Rank_aggregator.median,Rank_aggregator.mc4]) :
			raise ValueError("estimator passed isn't supported")

		is_mc4 = False
		if estimator == Rank_aggregator.mc4 :
			is_mc4 = True

		silent = open(os.devnull, 'w') #start silencing stdout (becouse of R prints something)
		normal = sys.stdout

		sys.stdout =silent
		#--------------------------- calling the bba_par_ranker R function
		rank = Rank_aggregator.R["bba_par_ranker"](dataframe=self.get_dataframe_rank(R=True),k_max=self.get_k_max(),col_discarded=self.get_col_metadata(),Nite=N_ite,est=estimator,MC4=is_mc4)

		sys.stdout = normal
		silent.close() # finishing silencing stduot


		#----------------------------- setting the rank
		self.last_rank = Rank_aggregator.list_from_dataframe(rank)	
		#--------------------------- returning a list
		return self.get_aggregated_rank()



	def random_ranker(self) :

		#------------------- computes the random ranking by position, in Python

		rank =self.get_dataframe_rank()
		rank = [list(i) for i in zip(*rank)]

		for i in range(0,self.get_col_metadata()) :
			del rank[0]

		l = len(rank)
		for i in range(self.get_k_max(),l) :
			del rank[-1]
		
		res = []
		unique = set()

		for i in rank :
			s = set(i) - unique
			res = res + list(s)
			unique = unique | s

		for i in range(0,len(res)) :
			res[i] = (res[i],float(i+1))

		#----------------------------- setting the rank

		self.last_rank = res

		#--------------------------- returning a list

		return res






	def no_of_app_ranker(self) :

		#------------------------ aggregator that counts the number of appearences, in Python


		rank =self.get_dataframe_rank()
		rank = [list(i) for i in zip(*rank)]

		for i in range(0,self.get_col_metadata()) :
			del rank[0]

		l = len(rank)


		for i in range(self.get_k_max(),l) :
			del rank[-1]

		d = {}
		for i in rank :
			for j in i :
				if j in d :
					d[j] = d[j] + 1
				else  :
					d[j] = 1

		f ={}

		for k in d :
			if d[k] in f :
				f[d[k]].append(k)
			else :
				f[d[k]] = [k]
		app = list(f.keys()) 
		app.sort(reverse=True)

		res = []

		for i in app :
			z = zip(f[i],[float(len(res)+len(f[i])/2)]*len(f[i]))

			res.extend(z)

		#----------------------------- setting the rank
		self.last_rank = res

		#--------------------------- returning a list

		return res


	def borda_count_ranker(self,estimator=mean) :

		if estimator not in set([Rank_aggregator.mean,Rank_aggregator.minimum,Rank_aggregator.median]) :
			raise ValueError("estimator passed isn't supported")

		#--------------------------- calling the borda_count_ranker R function
		rank = Rank_aggregator.R["borda_count_ranker"](dataframe=self.get_dataframe_rank(R=True),k_max=self.get_k_max(),col_discarded=self.get_col_metadata(),est=estimator)


		#----------------------------- setting the rank
		self.last_rank = Rank_aggregator.list_from_dataframe(rank)	
		#--------------------------- returning a list
		return self.get_aggregated_rank()


	def mc4_ranker(self,alpha=0.05) :

		#------------------------ check alpha value
		a = float(alpha)

		if a <=0 or a > 1 :
			raise ValueError("alpha has to be in the range 0<alpha<=1")

		#--------------------------- calling mc4_ranker R function
		rank = Rank_aggregator.R["mc4_ranker"](dataframe=self.get_dataframe_rank(R=True),k_max=self.get_k_max(),col_discarded=self.get_col_metadata(),alpha=a)


		#----------------------------- setting the rank
		self.last_rank = Rank_aggregator.list_from_dataframe(rank)	
		#--------------------------- returning a list
		return self.get_aggregated_rank()






# def parser() :
# 	args = sys.argv
# 	parser = ap.ArgumentParser(description='utilityes for the aggregation of rankings',formatter_class=ap.ArgumentDefaultsHelpFormatter)
# 	arg = parser.add_argument
# 	arg( 'inp_f', metavar='INPUT_FILE', type=str, help="the .csv with rankings")
# 	arg( '-c','--col-metadata',metavar='col_met', type=int, default='PAM', help="the number of columns to be discarded\n")
# 	arg( '-e','--k_max',metavar='k_max', type=int,default='SI', help="the number of first elements to use in every list \n")
# 	arg( '-h','--data_header',metavar='DIST_F', type=bool,default='Bray-Curtis', help="the distance function that has to be used\n")


	
# 	a = vars(parser.parse_args())






def testing() :
	mat =[ ["human", "dolphin", "cat", "mouse"],
                ["monkey","dolphin", "dog","mouse"],
                ["human","wolf","cat","dog"] ]
	# print mat
	r = Rank_aggregator(data=mat,k_max=3)


	print "bba  ",r.bba_par_ranker()
	print "bba mc4 ",r.bba_par_ranker(estimator=Rank_aggregator.mc4)
	print "rand  ",r.random_ranker()
	print r.get_aggregated_rank()
	print "nofap  ",r.no_of_app_ranker()
	print "borda  ",r.borda_count_ranker()
	print "mc4 ",r.mc4_ranker()
	print r.get_aggregated_rank()
	
	# print r.precision_computator()
	

if __name__ == '__main__':
	# testing()
	pass
