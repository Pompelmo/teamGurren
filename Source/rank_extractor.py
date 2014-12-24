from os import listdir
import csv
from numpy import matrix


def table_creator(rank_list,ouput_p) :
	
	# files = listdir(input_folder)
	# # print files

	# ext_files = []
	# for i in files:
	# 	if "expansion" in i : ext_files.append(i)
	# # print ext_files

	# # o = open(ouput_p,"w")
	# # ocsv = csv.writer(o,lineterminator="\n",delimiter=",")

	# # s = 50000

	# row_list = []

	# for e in ext_files :
	# 	# print e
	# 	i = open(input_folder+"/"+e,"r")
	# 	r = list(csv.reader(i))
	# 	i.close()

	# 	meta = []

	# 	if not discard_metadata :
	# 		meta = r[0][0].split()
	# 		del meta[0:2]

	# 		meta.append(meta[1])
	# 		del meta[1]

	# 		if len(meta) == 2 :
	# 			meta.insert(0,"0.05")

	# 		# print meta
	# 		#-------------blb
	# 		meta[0] = float(meta[0])
	# 		meta[1] = int(meta[1])
	# 		meta[2] = int(meta[2])
	# 		#---------------- blb
	# 		# print meta


	# 	del r [0:2]
	# 	r = matrix(r).T.tolist()[1][0:leng]
	# 	# print len(r)
	# 	# print r[0]
	# 	# if len(r)< s : s = len(r)

	# 	row = meta + r
	# 	row_list.append(row)


	
	# if not discard_metadata :
	# 	row_list =sorted(row_list,cmp=sorter)

	o = open(ouput_p,"w")
	ocsv = csv.writer(o,lineterminator="\n",delimiter=",")

	for i in rank_list :
		ocsv.writerow(i)

	o.close()


def extractor(input_folder,leng,discard_metadata =True) :

	files = listdir(input_folder)
	# print files

	ext_files = []
	for i in files:
		if "expansion" in i : 
			ext_files.append(i)
	# print ext_files

	# o = open(ouput_p,"w")
	# ocsv = csv.writer(o,lineterminator="\n",delimiter=",")

	# s = 50000

	row_list = []

	for e in ext_files :
		# print e
		i = open(input_folder+"/"+e,"r")
		r = list(csv.reader(i))
		i.close()

		meta = []

		if not discard_metadata :
			meta = r[0][0].split()
			del meta[0:2]

			meta.append(meta[1])
			del meta[1]

			if len(meta) == 2 :
				meta.insert(0,"0.05")

			# print meta
			#-------------blb
			meta[0] = float(meta[0])
			meta[1] = int(meta[1])
			meta[2] = int(meta[2])
			#---------------- blb
			# print meta


		del r [0:2]
		r = matrix(r).T.tolist()[1][0:leng]
		# print len(r)
		# print r[0]
		# if len(r)< s : s = len(r)

		row = meta + r
		row_list.append(row)


	
	if not discard_metadata :
		row_list =sorted(row_list,cmp=sorter)

	return row_list

def sorter(a,b) :
	if a[0]!=b[0] : 
		if a[0]>b[0] :return 1
		else : return -1

	elif a[1]!=b[1] : 
		return a[1] - b[1]
	
	else : return a[2] - b[2]


if __name__ == '__main__':
	# rl = extractor("../../data/GadW/expansion",leng=55,discard_metadata=True)
	# table_creator(rl,"../input/GadW_55__.csv")
