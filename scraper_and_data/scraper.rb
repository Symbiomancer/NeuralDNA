# A user needs to call three functions to download all of the data needed.
# (First get the table data by manually running the javascript in the console)
# First run get_and_write_url() to find the next url (I made a mistake here so this is why we have the next function call)
# Since I accidentily found the wrong url, you need to pull the information 
# from the url and create a new url that points to the genome sequence page.
# That function call is change_urls().
# Once you have all of the urls you need you can save the sequence files using
# get_genomes().

# NOTE!!!! Please be careful how many things you download at once. The server
# might kick you off if you download too many things at once. I ran level 1 at
# 20 genomes at a time. Since level 0 has so few you can run that all at once

# Notes on the parameters of the function and how to run this:
# The "level" numbers correspond to the colors in the Plants-Species-Origins file
# level 0 = Green, level 1 = White, level 2 = Yellow, level 3 = Red, level 4 = Purple,
# level 5 = in the database but not in the list, level 6 = yellow with no region label

require 'open-uri';
require 'csv';

# The website has a two step path traversal. The first link
# is stored in the .csv. The second link is on that page and
# needs to be found. This function finds that link
def get_next_link(url)
	file = open(url);
	contents = file.read;
	nurl = 'http://www.ncbi.nlm.nih.gov'
	if (contents =~ /(\/nuccore\/\d+\?report=fasta)/)
		nurl += $1
	else puts "no" end
	# puts contents;
	file.close();
	return nurl;
end

# This reads the genome in fasta format by following the link
# and saves the genome in its own file in the relavant level
def save_file(url,id,level="0")
	file = open(url)
	contents = file.read;
	File.open("scraped_genomes/level_" + level + "/" + id, "w"){ |file|
		file.write(contents)
	}
	file.close();
end

# Downloads all genomes that have the genome link in the .csv file
# Do this by each level. Be careful not to do too many at a time
def get_genomes(from=1,to=627,level="0",filename="scraped.csv")
	arr = CSV.read(filename)
	print "searching"
	(from...to).each do |i|
		if (arr[i][8] == level)
			print " found\n"
			if (arr[i][11] != nil && !File.exists?("scraped_genomes/level_" + level + "/" + arr[i][0]))
				save_file(arr[i][11],arr[i][0],level)
				puts ("done " + arr[i][0])
				print "sleeping "
				sleep(10)
			else
				print "nevermine"
			end
			print " continue"
			print " searching"
		end
	end
	print "\n finished"
end

# Uses get_next_link function to get the next links for the genomes.
# Specify which level you would like to get. Be careful not to get too
# many at once otherwise the server will kick you off
def get_all_next_urls_from_csv(from=1,to=627,level="0",filename = "scraped.csv")
	arr = CSV.read(filename)
	print "searching"
	(from...to).each do |i|
		if (arr[i][8] == level)
			print " found\n"
			if (arr[i][10] == nil)
				link = get_next_link(arr[i][2])
				arr[i][10] = link
				puts ("done " + i.to_s)
				print "sleeping "
				sleep(10)
			else
				print "nevermind"
			end
			print " continue"
			print " searching"
		end
	end
	print "\n finished"
	return arr
end

# Oops...actually needed a different url. Lets change current url to new one
# Accidentally got the wrong url in get_next_link. However, it did have
# all of the information needed. Use this information to create the correct link/
# Always run this after running get_all_next_urls_from_csv.
def change_urls(filename="scraped.csv",nfilename="new_scraped.csv")
	arr = CSV.read(filename)
	(0...arr.size).each do |i|
		if (arr[i][10] != nil && arr[i][11] == nil)
			if (arr[i][10] =~ /http:\/\/www\.ncbi\.nlm\.nih\.gov\/nuccore\/(\d+)\?report=fasta/)
				arr[i][11] = "http://www.ncbi.nlm.nih.gov/sviewer/viewer.fcgi?val=" + $1 + "&db=nuccore&dopt=fasta&extrafeat=0&fmt_mask=0&maxplex=1&sendto=t&withmarkup=on&log$=seqview&maxdownloadsize=1000000"
			else
				puts "nope"
			end
		end
	end
	write_to_csv(arr,nfilename)
end

# Write the data to a new .csv file
def write_to_csv(data,filename = "new_scraped.csv")
	CSV.open(filename, "wb") do |csv|
	  	data.each {|x| csv << x}
	end
end

# Use get_all_next_urls_from_csv to get all of the next urls and save them
# in a new .csv
def get_and_write_next_url(from = 1, to=627,level="0",filename = "scraped.csv", nfilename = "new_scraped.csv")
	arr = get_all_next_urls_from_csv(from,to,level,filename)
	write_to_csv(arr,nfilename)
end
# puts get_next_link('http://www.ncbi.nlm.nih.gov/genome/37072?genome_assembly_id=229804')