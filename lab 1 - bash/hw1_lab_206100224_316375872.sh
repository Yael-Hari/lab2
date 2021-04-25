#!/bin/bash


#---------------------------------------------------------------------
#		Question 1
#---------------------------------------------------------------------

#make the file lowercase
cat Alice_book | awk '{print tolower($0)}' > lower_Alice_book

#remove punctuations
sed 's/[[:punct:]]//g' < lower_Alice_book > no_punctuations_Alice_book



stop_words=(a about above across after afterwards again against all almost alone along already also although always am among amongst amoungst amount an and another any anyhow anyone anything anyway anywhere are around as at back be became because become becomes becoming been before beforehand behind being below beside besides between beyond bill both bottom but by call can cannot cant co computer con could couldnt cry de describe detail do done down due during each eg eight either eleven else elsewhere empty enough etc even ever every everyone everything everywhere except few fifteen fify fill find fire first five for former formerly forty found four from front full further get give go had has hasnt have he hence her here hereafter hereby herein hereupon hers herself him himself his how however hundred i ie if in inc indeed interest into is it its itse keep last latter latterly least less ltd made many may me meanwhile might mill mine more moreover most mostly move much must my myse name namely neither never nevertheless next nine no nobody none noone nor not nothing now nowhere of off often on once one only onto or other others otherwise our ours ourselves out over own part per perhaps please put rather re same see seem seemed seeming seems serious several she should show side since sincere six sixty so some somehow someone something sometime sometimes somewhere still such system take ten than that the their them themselves then thence there thereafter thereby therefore therein thereupon these they thick thin third this those though three through throughout thru thus to together too top toward towards twelve twenty two un under until up upon us very via was we well were what whatever when whence whenever where whereafter whereas whereby wherein whereupon wherever whether which while whither who whoever whole whom whose why will with within without would yet you your yours yourself yourselves)

#remove stop words
for i in "${stop_words[@]}"
do
    sed -i -e "s/\<$i\>\s*//g" no_punctuations_Alice_book
done 


#removes trailing spaces
awk '{$1=$1};1' < no_punctuations_Alice_book > no_spaces_Alice

#remove empty lines, with or without spaces
sed '/^[[:space:]]*$/d' < no_spaces_Alice > no_emptyLines_Alice



#make a "chapters" directory and split into chapters
mkdir chapters
cp no_emptyLines_Alice chapters
cd chapters
awk '{ print > "chapter_"i++ }' RS='chapter ' no_emptyLines_Alice
rm chapter_0
rm no_emptyLines_Alice

for chap in chapter_*
do

	#removes trailing spaces
	awk '{$1=$1};1' < $chap > temp


	#remove empty lines, with or without spaces
	sed '/^[[:space:]]*$/d' < temp > $chap	
done

rm temp
cd ..


#---------------------------------------------------------------------
#		Question 2
#---------------------------------------------------------------------


# Most common pair in the book
awk  '
	function sorted(a,b){
		if (a < b) return a " " b;
		else return b " " a;
	}

	{
	for (i = 1; i < NF; i++)
		if ($i < $(i+1)) a[$i OFS $(i+1)]++
		else             a[$(i+1) OFS $i]++
	}
	END {
	for (words in a)
		if (a[words] > a[m]) m = words
	{split(m,b); print "Most common pair in the book:", sorted(b[1],b[2])} 
    }' no_emptyLines_Alice



#Most common first word in the book
awk  '
    {
        a[$1]++
    }
    END{
        for (words in a)
            if (a[words] > a[m]) m = words
	{print "Most common first word in the book:", m}
    }' no_emptyLines_Alice



#loop through chapters: to get most common pair and most common first word


cp no_emptyLines_Alice chapters
cd chapters
r=0
for chap in {1..12}
do	
	# Most common pair in chapter #chap
	awk  '		
		function sorted(a,b)
		{
			if (a < b) return a " " b;
			else return b " " a;
		}
		{
		for (i = 1; i < NF; i++)
			if ($i < $(i+1)) a[$i OFS $(i+1)]++
			else             a[$(i+1) OFS $i]++
		}
		END {
			for (words in a)
				if (a[words] > a[m]) m = words

			{
				split(m,b); n='"$chap"';
				{printf("Most common pair for chapter %d: ", n); print sorted(b[1],b[2])}
			} 
    		}' "chapter_"$chap


	#Most common first word in the book
	awk  '
		{
		a[$1]++
		}
		END{
			for (words in a)
				if (a[words] > a[m]) m = words

			{
				p='"$chap"';
				{printf("Most common first word for chapter %d: ", p); print m}
			}
		}' "chapter_"$chap




done


rm no_emptyLines_Alice
cd ..




#---------------------------------------------------------------------
#		Question 3
#---------------------------------------------------------------------



#average num of words in every line & num of shorter then average lines
awk ' 
	{
		sum+=NF
		a[i++]=NF
	}
	END{
		average = sum/NR

		for (len in a)
			if (a[len]< average) short_lines+=1

		{printf ("Average line length: %.1f\n", average)}
		{print "Number of lines shorter than the average:", short_lines}
		
	}' no_emptyLines_Alice


#---------------------------------------------------------------------
#		Question 4
#---------------------------------------------------------------------


# average location of "alice" in each line

awk '
	{
		for (i=1; i<=NF; i++)
        {
			{if ($i=="alice") sum+=i}
           	{if ($i=="alice") count+=1}
		}
	}
    END{
		average=sum/count
		{printf("Average place of Alice in a line: %.1f\n", average)}

	}' no_emptyLines_Alice


#remove not needed files

rm no_spaces_Alice
rm no_punctuations_Alice_book
rm no_emptyLines_Alice
rm lower_Alice_book