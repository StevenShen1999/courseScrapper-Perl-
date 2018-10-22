#!/usr/bin/perl -w

if ($#ARGV < 1 || $#ARGV > 1){
    print ("Usage: ./courseScrap.pl [COURSE] T[123]\n");
    exit 1;
}

$website = "http://classutil.unsw.edu.au/";

##First get the course code
if ($ARGV[0] =~ /^[A-Z]{4}/){
    ($course) = ($ARGV[0] =~ /^([A-Z]{4}[0-9]{4})/);
} else {
    print ("Error: Bad course code\n");
    exit 1;
}

##Then the semester
if ($ARGV[1] =~ /^T([1-3])/){
    ($semester) = ($ARGV[1] =~ /^(T[1-3])/);
} else {
    print ("Error: Bad semester number\n");
    exit 1;
}

$url = $website . "COMP_$semester.html#" . "$course$semester";
open webPage, "-|", "wget -q -O- $url" or die;

while ($line = <webPage>){
    chomp $line;
    if ($line =~ /cucourse/ and $line =~ /$course/){
        $found = 1;
    } elsif (defined $found and (not defined $counter or $counter < 1)){
        if (not defined $counter){
            $counter = 0;
        } else {
            $counter += 1;
        }
    } elsif (defined $counter and $counter == 1) {
        ($slots_open) = ($line =~ />([0-9]*)\//);
        ($total_slots) = ($line =~ /\/([0-9]*)</);
        last;
    }
}

if ($slots_open < $total_slots){
    print("Course is avaliable, current enrolment status $slots_open\/$total_slots \n");
} else {
    print("Course is full, current enrolment status $slots_open\/$total_slots 100%\n")
}