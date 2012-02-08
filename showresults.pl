#!/usr/bin/perl -w

use CGI qw(:all);

@courses = param("course");
@semesters = param("semester");
@instructors = param("instructor");
@outcomes = param("outcome");
$pos = param("sorto");
$selectAll = param("selAll");
@topdirs = ();
@matched = ();
$search = "";
$datadir = "/var/www/virtual/abetdata.olin.edu/html/data/";
@work = ();
@final = ();
@scratch = ();
@final_results = ();
$work_out = "";
$work_name = "";
$wild = "/*";
$maxCols = 10;
$webPath = '<a href="http://abetdata.olin.edu/data/';
$q = new CGI;
$mod = 0;
$bgcolor = "";
$good = 0;
$mdate = "";

$ENV{'PATH'} = '/bin:/usr/bin';
delete @ENV{'IFS', 'CDPATH', 'ENV', 'BASH_ENV'};
my $path = $ENV{'PATH'};
if ($selectAll eq "Select All") {
    $#courses = -1;
    $#semesters = -1;
    $#instructors = -1;
    $#outcomes = -1;
}

if ( $#courses < 0) {
    push(@courses, '*');
}
if ( $#semesters < 0) {
    push(@semesters, '*');
}
if ( $#instructors < 0) {
    push(@instructors, '*');
}

#for ($i=0; $i<=$#courses; $i++) {
#    if( $courses[$i] eq "CS3723") {
#        $courses[$i] = $courses[$i] . '*';
#    }
#}

print $q->header,
	$q->start_html("Selection Results"),
	$q->h1("Results");

for ($i=0; $i<=$#courses; $i++) {
    for ($j=0; $j<=$#semesters; $j++) {        
            for ($k=0; $k<=$#instructors; $k++) {
                $search = $courses[$i];
                $search .= "-" . $semesters[$j];
                $search .= "-" . $instructors[$k];
                push(@topdirs, $search);
            }
    }
}

for ($i=0; $i<=$#topdirs; $i++) {
    $search = $datadir . $topdirs[$i];
    @scratch = ( glob("$search") );
    for ($l=0; $l<=$#scratch; $l++) {
	$k=0;
	for ($j=0; $j<=$#matched; $j++) {
		if ($matched[$j] eq $scratch[$l] ) {
			$k = 1;
		}
	}
	if ($k == 0 ) {
            if ($scratch[$l] =~ "HASH") {   
            }
	    else {
                push(@matched, $scratch[$l]);
            }
	}
    }
}

for ($i=0; $i<=$#matched; $i++) {
        $search=$matched[$i] . $wild;
	@work = glob("$search");
        for ($j=0; $j<=$#work; $j++) {
            @trec = split(/\//, $work[$j]);
            $work_out='Z';
            ($work_name, $work_id, $work_out) = split(/-/, $trec[$#trec]);
#	    ($work_name, $work_id) = split(/\#/, $work_name);
            $#trow = -1;
	    for ($l=0; $l<=$maxCols; $l++) {
		push(@trow, " ");
	    }
            if ( $#outcomes < 0) {
                @trow = split(/-/, $matched[$i]);
		@tval = split(/\//, $trow[0]);
		$trow[0] = $tval[$#tval];           
                $trow[3] = $work_name;
		$trow[4] = $work_id;
                $trow[5] = $work_out;
                push(@trow," ");
                push(@trow," ");
                push(@trow," ");
                push(@trow," ");
                push(@trow," ");
		$search = $work[$j] . $wild;
		$#final = -1;
                @final = glob("$search");
                #print $q->p("FINAL = @final");
                for ($l=0; $l<=$#final; $l++) {
		    if ($final[$l] =~ "Instructions") {
                     #   print $q->p("$l--$final[$l]");
                        $trow[6] = build_link();
                    }                                            
		    if ($final[$l] =~ "Best") {    
			$trow[7] = build_link();	
                    }
                    if ($final[$l] =~ "Average") {
                        $trow[8] = build_link();
                    }
                    if ($final[$l] =~ "Worst") {
                        $trow[9] = build_link();
                    }
                    if ($final[$l] =~ "Solution") {
                        $trow[10] = build_link();
                    }

                }
            }
            else {
                for ($k=0; $k<=$#outcomes; $k++) {
                    if ($work_out =~ $outcomes[$k] ) {
                        @trow = split(/-/, $matched[$i]);
			@tval = split(/\//, $trow[0]);
			$trow[0] = $tval[$#tval];
        		$trow[3] = $work_name;
			$trow[4] = $work_id;
			$trow[5] = $work_out;
                        push(@trow," ");
                        push(@trow," ");
                        push(@trow," ");
                        push(@trow," ");
                        push(@trow," ");
			$search = $work[$j] . $wild;
			$#final = -1;
			@final = glob("$search");
			for ($l=0; $l<=$#final; $l++) {
			    if ($final[$l] =~ "Instructions") {
			        $trow[6] = build_link();
			    }
			    if ($final[$l] =~ "Best") {
				$trow[7] = build_link();	
			    }
                            if ($final[$l] =~ "Average") {
                                $trow[8] = build_link();
                            }
			    if ($final[$l] =~ "Worst") {
			        $trow[9] = build_link();
			    }
                            if ($final[$l] =~ "Solution") {
                                $trow[10] = build_link();
                            }

			}
                    }
                }
            }
            $x = length($trow[5]);
            if ($x > 1) {
                $tstr="";
                for ($l=0; $l<$x; $l++) {
                    if ($l == ($x-1)) {
                        $tstr .= substr($trow[5], $l, 1);
                    } 
                    else {
                        $tstr .= substr($trow[5], $l, 1) . ",";
                    }
                }
                $trow[5] = $tstr;
            }
	    else {
                if ($x == 0) {
#                    print $q->p("Here >$trow[5]<");
                    $trow[5] = 'Z';
                    
                }
            }
            if ( length($trow[0] ) > 1 ) {
                push ( @final_results, [@trow] );
            }
	}
}

#for ($i=0; $i<=$#final_results; $i++) {
#        for ($j=0; $j<=$maxCols; $j++) {
#            print $q->p($final_results[$i][$j]);
#        }
#        print $q->end_Tr;
#}


#print $q->p("Sort = $pos");

#@final_results = sort {$a->[$pos] <=> $b->[$pos]} @final_results;
if ( $pos == 5 ) {
    for ($i=0; $i<=$#final_results; $i++) {
        $len = 0;
        $len = length($final_results[$i][5]);
        if ( $len > 1 ) {
            @oc = split(/,/, $final_results[$i][5]);
            $final_results[$i][5] = $oc[0];
            $#trow = -1;
            for ($j=0; $j<=$maxCols; $j++) {
               push (@trow, $final_results[$i][$j]); 
            }
            for ($j=1; $j<=$#oc; $j++) {
                $trow[5] = $oc[$j];
                push (@final_results, [@trow])
            }
        }
    }
}

##@final_results = sort {$a->[$pos] cmp $b->[$pos]} @final_results;

@final_results = sort { $a->[$pos] cmp $b->[$pos] or $a->[3] cmp $b->[3] or $a->[4] <=> $b->[4] } @final_results;

for ($i=0; $i<=$#final_results; $i++) {
    if ($final_results[$i][5] eq 'Z') {
        $final_results[$i][5] = " ";
    }
}        
#
# Print the results
#
if ($#final_results >= 0) {
print $q->start_table({-width=>'100\%', -border=>'0'});
print $q->start_Tr;
print $q->start_th({align=>'left'}), "COURSE", $q->end_th;
print $q->start_th({align=>'left'}), "SEMESTER", $q->end_th;
print $q->start_th({align=>'left'}), "INSTRUCTOR", $q->end_th;
print $q->start_th({align=>'left'}), "EXHIBIT", $q->end_th;
print $q->start_th({align=>'left'}), "ID", $q->end_th;
if ( $pos == 5 ) {
    print $q->start_th({align=>'left'}), "OUTCOME", $q->end_th;
}
else {
    print $q->start_th({align=>'left'}), "OUTCOME(S)", $q->end_th;
}
print $q->start_th({align=>'left'}), "INSTRUCTIONS", $q->end_th;
print $q->start_th({align=>'left'}), "BEST", $q->end_th;
print $q->start_th({align=>'left'}), "AVERAGE", $q->end_th;
print $q->start_th({align=>'left'}), "WORST", $q->end_th;
print $q->start_th({align=>'left'}), "SOLUTION", $q->end_th;
print $q->end_Tr;


    for ($i=0; $i<=$#final_results; $i++) {
        $mod = $i % 2;
        if ( $mod ) {
            $bgcolor = '#FFFFFF';
        }
        else {
            $bgcolor = '#F0F0F0';
        }
        print $q->start_Tr;
        for ($j=0; $j<=$maxCols; $j++) {
            print $q->start_td({bgcolor=>"$bgcolor"}), $final_results[$i][$j], $q->end_td;
        }
        print $q->end_Tr;
    }
print $q->end_table;
get_file_date();
print $q->p("Last Updated: $mdate");
}
else {
    print $q->h2("No results were found ...");
}

print $q->end_html;

sub build_link {
    $#tval=-1;
    @tval = split(/\//, $final[$l]);
    $tstr = $webPath;
    for ($m=7; $m<=$#tval; $m++) {
	$tstr .= $tval[$m];
	if ( $m<$#tval ) {
	    $tstr .= "/";
	}
    }
    $tstr .= '">' . $tval[$#tval] . '</a>'; 
}

sub get_file_date {
    $cmd = "ls --full-time $datadir";

    open(PPIPE, "$cmd |") || die "ERROR: No Pipe\n\n";

    while (<PPIPE>) {
        chomp;
        @rec = split;
#    print("$rec[$#rec-2]\n");
        $mdate = $rec[$#rec-3];
    }
    close(PPIPE);

}
