:mod:`rank_extractor` --- Processing of PCIM data
=======================================================


This module offers a way to process the output of ParserBoinc.py and aggregate 
all the rankings in a list ready to be postrocessed. The functions of
this module use ony the .expansion files 

.. function:: extractor(input_folder,leng)

	take in input a string *input_folder* containing a path of a directory containing the output of ParserBoinc of many
	PCIM,	an integer *leng* that is the number of first elements to extract from every PC-IM.
	Return a list of ranks taken from every PCIM in the input folder.



.. code-block :: python
	
	from rank_extractor import extractor
	my_folder = "./myfolder" # the folder with the data

	l = extractor(myfolder,55) # extract 55 element for every PC-IM results in the folder (the ranks), and return a list of ranks 

.. .. function:: table_creator(rank_list,ouput_p)

.. 	take in input the list of rank *rank_list* and a string *output_p* containing the parth of the file where
.. 	to save a .csv of the 
