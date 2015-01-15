
:mod:`rank_aggregation` --- Utilities for aggregation of rankings
=======================================================

.. module:: rank_aggregation
   :synopsis: Objects for aggregation of rankings


This module offers a structured way to aggregate rankings in several different
ways. It can be used to process all types of rankings.
The real implementation of a part of these functions is made in R, but this is 
hidden to the user thanks to some linkage libraries, required by this module
and described in the next section.


Requirements
------------

In order to run correctly this module you need to have installed correctly in
your machine the following stuffs:

* Python2

* The R software environment by CRAN, avaible `here <http://www.r-project.org/>`_.

* The R libaries "markovchain" and "hash" and all their dependancies, you can learn how 
  to install a R library `here <http://www.r-bloggers.com/installing-r-packages>`_.

* The `rpy2 <http://rpy.sourceforge.net/>`_ library for linking python and R

* The file "Funzioni_2.0.R" (containing the R implementation of part of the functions) 
  in the same folder of the file "rank_aggregation.py"

.. note::

   If you have some troubles installing these component please refer to the 
   official documentation of that tools


For beeing sure that everything is configured correctly you can simply
open your python interpreter and type

.. code-block :: python

  >>> from rank_aggregation import Rank_aggergator 
  >>> from rpy2.robjects.packages import importr
  >>> h = importr("hash")
  >>> m = importr("markovchain")

if there aren't errors you are ready to start using this module


Ranking data
-----------

Before starting explaining the functions is better tu introduce the concept of Ranking. 
For the logic of this module a rank is a ordered list with omogeneous len > 1 of string from position 1 to len of the 
list. The usual input of this library is a list of ranking or a .csv file where every row contains
a ranking (and so every column contains all the element from every rank having the same position).

Obviously some elements have to be present in more than one rank otherwise it's impossible 
the aggregation of rankings without other informations

.. code-block :: python
	
	# this is an accepted list of rank
	rank_list = [ ["human", "dolphin", "cat", "mouse"],
	 		["monkey","dolphin", "dog","mouse"],
	 		["human","wolf","cat","dog"] ]

.. note::

   As you can see in the example the rankings need to have the same  length, and also it has to be > 1



Class and funcions
--------------

.. class:: Rank_aggregator(data=None,col_metadata=0,data_header=False,k_max=None)



	Create an instance of the classes :class:`Rank_aggregator`. 
	*data* is a list of rankings or a path of a .csv file with the rankings on the row.
	*col_metadata* is an integer representing the number of columns that has to be discarded from data starting
	from the first 
	*data_header* is a boolean flag that , if it is set to True the first row of data will be discarded. 
	*k_max* is the len of the ranks to be aggregated

	Rank_aggregator's instances provide the following methods:

.. method:: Rank_aggregator.set_dataframe_rank(data,data_header=False)

		Set the list of ranks that has to be aggregated from *data*, *data_header* is a flag that if true says 
		that the first row is the header. data can be also a .csv file with a rank for every row (so the column are
    the positions)

.. method:: Rank_aggregator.get_dataframe_rank() 

		Return the list of ranking that was set in this istance of Rank_aggregator, raise *ValueError* if 
		there's no data

.. method:: Rank_aggregator.set_k_max(k_max)

		Takes an integer *k_max* and sets it to the length of the rank to be aggregated

.. code-block :: python

      # this is our list, if we set the k_max = 4 the lists will be used entirely
      rank_list = [ ["human", "dolphin", "cat", "mouse"],
          ["monkey","dolphin", "dog","mouse"],
          ["human","wolf","cat","dog"] ]

      #if we set k_max = 2 the lists will be used like they were
      rank_list = [ ["human", "dolphin"],
          ["monkey","dolphin"],
          ["human","wolf"] ] 
      #so if you want to use all the elem of the list tou simply set k_max = len(rank_list[0]) in this example

.. method:: Rank_aggregator.get_k_max()

		Returns an integer that is the len of the rank to be aggregated


.. method:: Rank_aggregator.set_col_metadata(col)

		Set the number of the first columns that has to be considered metadata and so not used in the 
		ranking aggregation

.. method:: Rank_aggregator.get_col_metadata()

		returns an integer representing the number of the first columns that are considered metadata and so
		discarded during the ranking aggregation

.. method:: Rank_aggregator.get_aggregated_rank()

    returns the result of the last aggregation

Now an example of using these methods to create a working instance of Rank_aggregator

.. code-block :: python

  from rank_aggragtion import Rank_aggregator
  #we will use rank_list described in the previous example

  #this is an instance ready to being used
  r = Rank_aggregator(data=rank_list,col_metadata=0,data_header=False,k_max=4)

  #we can create an equivalent one simply adding the parameters after the creation
  t = Rank_aggregator()
  t.set_dataframe_rank(rank_list,data_header=False)
  t.set_col_metadata(0)
  t.set_k_max(4)

.. note::

Now will follow the description of the ranking methods implemented in *Rank_aggregator*, These require that 
the instance used is already set with all the data descried in the previous example. All the methods now described returns a 
list of tuples. the first element of every tuple is an element of the the aggregated rank, 
the second is the position of the  element in the rank. 
If there are tails the position will be the mean

.. method:: Rank_aggregator.no_of_app_ranker()

    Aggregate the ranks counting the number of times the elements appear in every list, and order them in 
    the final aggregated list from the one who has the highest number of appearence to the one who has less.
    Returns a list where the first elem is a the aggregated list and the second is the position

.. method:: Rank_aggregator.random_ranker()

    Aggregate picking elemens from all the first positions and randomly shiffling them. Iterate this procedure for the
    second position (appending these elements to the aggregated rank of the firsts) and so on.
    Returns a list where the first elem is a the aggregated list and the second is the position   

.. method:: Rank_aggregator.borda_count_ranker(estimator=Rank_aggregator.mean)

    Aggregate the ranks using the Borda count method.
    Returns a list where the first elem is a the aggregated list and the second is the position.

.. method:: Rank_aggregator.mc4_ranker(alpha=0.05)
    
    Aggregate the ranks usaing the mc4 method, *alpha* is the significance level. 
    Returns a list where the first elem is a the aggregated list and the second is the position.

.. method:: Rank_aggregator.bba_par_ranker(N_ite=1,estimator=Rank_aggregator.mean)

    Aggregate the ranks using the BRE method by Blanzieri et al. *N_ite* is the number of iteration
    if the algorithm. *estimator* is the function that has to be used to set the weigth, the avaible functions 
    are described below.
    Returns a list where the first elem is a the aggregated list and the second is the position.

The avaible estimator functions for :func:`bba_par_ranker` and :func:`borda_count_ranker` are:

.. attribute:: Rank_aggregator.mean
    
  the mean    

.. attribute:: Rank_aggregator.median

  the median

.. attribute:: Rank_aggregator.minimum

  the minimum

.. attribute:: Rank_aggregator.mc4

  a function that computes the weigths similar to *mc4_ranker*, THIS IS VALID ONLY FOR :func:`bba_par_ranker`

.. code-block :: python

  #this example is a continuum of the previous one

  a = r.borda_count_ranker(estimator = Rank_aggregation.mean) #use the borda count with the mean
  b = r.mc4_ranker() #use the mc4

  m = r.bba_par_ranker(N_ite = 2,estimator = Rank_aggregation.mean) #use bba_par with mean estimator
  n = r.bba_par_ranker(estomator = Rank_aggregation.mc4) #use bba_par with mc4 estimator





