# from numpy import matrix


__version__ = '0.2'

import os
import sys

#--------------------------------- rpy2 imports
import rpy2.robjects as robjects
from rpy2.robjects.packages import importr





class Rank_aggregator:
	"""Rank_aggregator object"""

	#---------------------------------- inizialization of class R environment and loading of R functions
	base= importr("base")
	robjects.r('source("Funzioni_2.0.R")')
	R = robjects.globalenv
	#--------------------------------------- costructor
	def __init__(self, data=None,col_metadata=None,data_header=False,classes=None,classes_header=False,k_max=None):


		#----------------------------------- creation of class variables
		# self.data = None
		self.Rdata = None
		self.col_metadata = 0
		self.kmax = None
		# self.classes = None
		self.Rclasses = None
		self.last_rank = None

		#------------------------------------ inizialization of data
		if data != None :
			self.set_dataframe_rank(data,data_header)

		#------------------------------------ inizialization of classes
		if classes != None :

			self.set_dataframe_classes(classes,classes_header)

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

		return [list(i) for i in zip(*l)] #return the transposed matrix

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

	def get_dataframe_rank(self) :
		if self.Rdata == None :
			raise ValueError("no rank data in this istance of Rank_aggregator")
		return self.Rdata


	def set_dataframe_rank(self,data,data_header=False) :
		if type(data) == str :
			if not os.path.exists(data) :
				raise IOError("'"+data+"' is not a readable file")

			self.Rdata = Rank_aggregator.dataframe_from_csv(data,row_header=data_header)
		
		elif type(data) == robjects.vectors.DataFrame :
			self.Rdata = data

		elif hasattr(data, '__iter__'):
			self.Rdata = Rank_aggregator.dataframe_from_list(data)

		else :
			raise TypeError(type(data)+" data type not supported")


	def get_dataframe_classes(self) :
		if self.Rclasses == None :
			raise ValueError("no classes data in this istance of Rank_aggregator")
		return self.Rclasses


	def set_dataframe_classes(self,classes,classes_header=False) :
		if type(classes) == str :
			if not os.path.exists(classes) :
				raise IOError("'"+classes+"' is not a readable file")
			self.Rclasses = Rank_aggregator.dataframe_from_csv(classes,row_header=classes_header)
		
		elif type(classes) == robjects.vectors.DataFrame :
			self.Rclasses = classes

		elif hasattr(classes, '__iter__'):
			self.Rclasses = Rank_aggregator.dataframe_from_list(classes)

		else :
			raise TypeError(type(classes)+" classes type not supported")		


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
		return self.last_rank

	def set_aggregated_rank(self,rank) :

		if type(rank) == str :
			if not os.path.exists(rank) :
				raise IOError("'"+rank+"' is not a readable file")

			self.last_rank = Rank_aggregator.dataframe_from_csv(rank)
		
		elif type(rank) == robjects.vectors.DataFrame :
			self.last_rank = rank

		elif hasattr(rank, '__iter__'):
			self.last_rank = Rank_aggregator.dataframe_from_list(rank)

		else :
			raise TypeError(type(rank)+" data type not supported")


	#------------------------------------------------ ranking functions

	def bba_par_ranker(self,N_ite=1,estimator="mean") :

		silent = open(os.devnull, 'w')
		normal = sys.stdout

		sys.stdout =silent
		#--------------------------- calling the bba_par_ranker R function
		rank = Rank_aggregator.R["bba_par_ranker"](dataframe=self.get_dataframe_rank(),k_max=self.get_k_max(),col_discarded=self.get_col_metadata(),Nite=N_ite)

		sys.stdout = normal
		#----------------------------- setting the rank
		self.last_rank = rank	
		#--------------------------- returning a list
		return Rank_aggregator.list_from_dataframe(rank)



	def random_ranker(self) :


		#--------------------------- calling the random_ranker R function
		rank = Rank_aggregator.R["random_ranker"](dataframe=self.get_dataframe_rank(),k_max=self.get_k_max(),col_discarded=self.get_col_metadata())


		#----------------------------- setting the rank
		self.last_rank = rank	
		#--------------------------- returning a list
		return Rank_aggregator.list_from_dataframe(rank)


	def no_of_app_ranker(self) :



		#--------------------------- calling the no_of_app_ranker R function
		rank = Rank_aggregator.R["no_of_app_ranker"](dataframe=self.get_dataframe_rank(),k_max=self.get_k_max(),col_discarded=self.get_col_metadata())


		#----------------------------- setting the rank
		self.last_rank = rank	
		#--------------------------- returning a list
		return Rank_aggregator.list_from_dataframe(rank)

	def borda_count_ranker(self) :



		#--------------------------- calling the borda_count_ranker R function
		rank = Rank_aggregator.R["borda_count_ranker"](dataframe=self.get_dataframe_rank(),k_max=self.get_k_max(),col_discarded=self.get_col_metadata())


		#----------------------------- setting the rank
		self.last_rank = rank	
		#--------------------------- returning a list
		return Rank_aggregator.list_from_dataframe(rank)


	def mc4_ranker(self,alpha=0.05) :

		#------------------------ check alpha value
		a = float(alpha)

		if a <=0 or a > 1 :
			raise ValueError("alpha has to be in the range 0<alpha<=1")

		#--------------------------- calling mc4_ranker R function
		rank = Rank_aggregator.R["mc4_ranker"](dataframe=self.get_dataframe_rank(),k_max=self.get_k_max(),col_discarded=self.get_col_metadata(),alpha=a)


		#----------------------------- setting the rank
		self.last_rank = rank	
		#--------------------------- returning a list
		return Rank_aggregator.list_from_dataframe(rank)


	def precision_computator(self,rank=None,classes= None,k_firsts=None) :

		if rank != None :
			self.set_aggregated_rank(rank)
		if classes != None :
			self.set_dataframe_classes(classes)

		kf = len(Rank_aggregator.list_from_dataframe(self.get_aggregated_rank())[0])
		if k_firsts != None :
			kf = int(k_firsts)

	 	
		val = Rank_aggregator.R["precision_computator"](dataframe_rank = self.get_aggregated_rank(),dataframe_classes=self.get_dataframe_classes(),k_firsts=kf)

		return val





def main():
	robjects.r('source("Rank_aggregation_KL.R")')

	# robjects.r('''bre <- function(dataframe,Nite=1,kmax=55,est=funct){



	# 	return(vector("numeric",length=4))
	# }''')


	bba_par_ranker =robjects.globalenv['bba_par_ranker']
	# first = robjects.globalenv['first']
	base= importr("base")
	# as_vector = robjects.globalenv['as.vector']

	df = robjects.vectors.DataFrame.from_csvfile("bigTable.csv",header=False)

	bba = bba_par_ranker(df,col_discarded=3)
	# print type(first(bba))
	# print list(first(bba))

	# print type(base.as_vector(bba[0]))
	# print list(base.as_vector(bba[0]))
	# print df


	aaa= base.data_frame(robjects.StrVector(["a","b"]))
	base.rbind(aaa,robjects.StrVector(["a","b"]))
	print aaa








def testing() :
	mat =[[1,2],["10","ciao"]]
	print mat
	r = Rank_aggregator(data="bigTable.csv",k_max="55",col_metadata="3")

	# print r.get_k_max()
	# print r.get_dataframe_rank()
	# row =r.get_dataframe_rank()

	# print row
	# print Rank_aggregator.list_from_dataframe(row)

	print r.bba_par_ranker()
	# print r.random_ranker()
	# print r.no_of_app_ranker()
	# print r.borda_count_ranker()
	# print r.mc4_ranker()
	# print r.precision_computator()
	

if __name__ == '__main__':
	# print dataframe_form_csv("bigTable.csv")
	# main()
	# print r.get_dataframe_classes() 


	testing()
