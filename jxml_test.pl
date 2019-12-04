use strict;
use warnings;
use Text::Diff;

my $arg = grep(/-v/, @ARGV);

opendir my $tests, "tests" or die "Cannot open directory: $!";
my @test_files = grep(/^t[0-9]+$/, readdir $tests);
closedir $tests;

opendir my $exp, "tests/exp" or die "Cannot open directory: $!";
my @exp_files = grep(/^t[0-9]+$/, readdir $exp);
closedir $exp;

my $num_tests = @test_files;
for (my $i=0; $i < $num_tests; $i++){
    # print"$test_files[$i]\n";
    # print"$exp_files[$i]\n";
    if($test_files[$i] ne $exp_files[$i]){
	die "missing test\n";
    }
    system("./build/jxml < tests/$test_files[$i] > tests/res/$test_files[$i] 2> tests/res/$test_files[$i]");
    if($arg == 1){
	system("valgrind ./build/jxml < tests/$test_files[$i] > tests/res/$test_files[$i]val 2> tests/res/$test_files[$i]val");
	my $vp = 0;
	open(my $vf, "<", "tests/res/$test_files[$i]val") or die;
	while (my $line = <$vf>) {
	    if ($line =~ /still reachable: [0-9,]+ bytes in 3 blocks/) {
		$vp = 1;
		last;
	    }
	}
	if($vp == 1){
	    printf "Test $test_files[$i] passes memory leak check!\n";
	}
	else{
	    printf "Test $test_files[$i] fails memory leak check!\n";
	}
    }
    my $diff = diff "tests/exp/$exp_files[$i]", "tests/res/$test_files[$i]", { STYLE => "Context" };
    if($diff eq ""){
	printf "Test $test_files[$i] pass!\n";
    }
    else{
	printf "Test $i fail!\n";
	print "$diff\n";
    }
    
}
