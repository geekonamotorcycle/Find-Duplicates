# Find-Duplicates.ps1 #
### Copyright 2017 Joshua Porrata<br>For private use only. For business use please contact localbeautytampabay@gmail.com for a low cost <br>license. Honor system rules###
----------

* **Why?**<br> 
Because I have a lot of duplicate and 0 byte images and I would like to know where they are so I can remove them.

* **How do I run this script?**
	*	run  `.\Find-Duplicates.ps1`
* **What are the defaults?**
	1. The script will ask for a source path

	2. The script will dump a CSV file of its initial scan. the name is `File_Hash_results.csv`. The initial scan can be lengthy so this file is dumped in case you need to pick up later.

	3. Two more CSV files are dumped: 
		1. `pFile_Hash_results.csv` (p) stands for positive and contains files with a greater than zero length. 
		2. `zFile_Hash_results.csv` (z) if zero length, these are essentially empty files.  <br>

	4. Finally a CSV named `Hash_Match_List.csv` and an `Out-Gridview` window will be shown.

* **How does it work?**<br>The script is split into several functions

	1. **Read-Paths**: asks for a source path and tests it

	2. **Get-HashObjects**: recurses through the source path and generates SHA1 Hashes.

	3. **Remove-ZeroLength**: increments goes through the results of <br>  Get-HashObjects and creates two CSV files, one of zero length files and one of positive length files.

	4. **Find-Hashmatch**: Brute force; Grabs the hash of the first line in the output and compares it to every other hash, when it finds 2 (1 match is always expected) or more matches it logs them and dumps out a CSV with the results.

* **Will this run on OSX, Linux, or Powershell `(version -ne 5.1)`**
	
	* I have no idea

* **It broke my computer,deleted files, exploded!**
	* There is no warranty or guarantee that this script will work the way you or I think 	it will. Good Luck.
*	**This seems terribly inefficient.**
	*	I'm no mathematician, but that sounds right. 

----------
#Functions, Switches, Inputs, Outputs, Class, Executions Order

```
#Read-paths 1.1
#grabs the source and destination root Paths and checks that they 
#exist before Passing them on.
#<Switches>
#	-Source will specify a source path Make sure its valid!
#	-Destination will specify a destination path Make sure its valid!
#	-findDestPath if $true, will ask for the destination Folder defualt $true
#<Outputs>
#	Output: $sourcePath the root of the folder we will be scanning.
#	OutPut: $destPath The root of the folder files will be headed to 
#Copyright 2017 Joshua Porrata, For private use only.


#Get-HashObject 0.8
#Recurses through a root folder, gathers file information and calculates SHA1 
#Hash Values
#<Switches>
#	-SourcePath Sepcify a root path, this can be manually specified or sent from 
#		$sourcePath from the Read-Paths Function. 
#	-DumpCSV if $true a CSV of the output object wil be dropped into the same 
#		Folder that the script was run from. Defaults $true
#<Outputs>
#	Output: $Script:LiveObject
#	Output: .\File_Hash_results.csv
# Copyright 2017 Joshua Porrata, For private use only.

#Remove-ZeroLength 0.8
#Iterates through the input array and seperates files of less than a specified 
#Length out and into a seperate array and then dumps them into a CSV file. 
#<Switches>
#	-LengthFilter, Minimum length a file must be to pass through the seperation
#		Default 1
#	-ArrayIn, the input array, in this script the array comes from 
#		Get-HashObject and is named $liveObject
#	-DumpCSV if $true a CSV of the output object wil be dropped into the same 
#		Folder that the script was run from. Defaults $true
#<Output>
#	Output: $PenultimateTable
#	Output: .\pFile_Hash_results.csv
#	Output: .\zFile_Hash_results.csv
# Copyright 2017 Joshua Porrata, For private use only.

#Find-HashMatch 0.8
#Makes two copies of the Hahsholder Obect in memory and iterates through them 
#using brute force to find if there is more than one match to a hash. A CSV is 
#written to disk of all matching Hashes 
#<Switches>
#	-DumpCSV if $true a CSV of the output object wil be dropped into the same 
#		Folder that the script was run from. Defaults $true
#	-InputArray The input array to be processed. This comes from 
#		Remove-ZeroLength and is named $PenultimateTable or, if null it will try
#		to find .\pFile_Hash_results.csv and import that.
#	-DisplayOutput, sends the final array to terminal with out-gridview. Be 
#		careful. defaults true.
#<Output>
#	Output: .\Hash_Match_list.csv
#	Output: Out-GridArray to terminal 
# Copyright 2017 Joshua Porrata, For private use only.

#class HashHolder {
#    [string]$FilePath
#    [string]$FilePath2
#    [string]$FileHash
#    [string]$FileHash2
#    [int]$Size
#    [int]$Size2
#    [datetime]$LastModified
#    [datetime]$LastModified2
#}

Default Execution Order.

Clear-Host
Copyright
Read-Paths -findDestPath $false
Get-HashObject -SourcePath $sourcePath -DumpCSV $true
Remove-ZeroLength -ArrayIn $liveObject -LengthFilter 1 -DumpCSV $true
Find-HashMatch -InputArray $PenultimateTable -DumpCSV $true -DisplayOutput $true

 ```


