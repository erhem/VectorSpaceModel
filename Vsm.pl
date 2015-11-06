#!/usr/bin/perl
use strict;
use warnings;

use feature "say";
use Data::Dumper qw (Dumper);

# Main Program
my $dok = "data/dok.txt";
my $koleksi = "data/koleksi.txt";
my $listwords = "data/listwords.txt";
my $hasil = "data/hasil.txt";
my %list = indexing($dok, $koleksi, $listwords, $hasil);

print Dumper \%list;

say "selesai.";

###

sub indexing {
	## open file dokumen
    open(DOK, "$_[0]") or die "can't open ";
	
    ## open file koleksi
    open(KOLEKSI," $_[1]") or die "can't open ";
	
	# open file listwords
	open(WORDS," $_[2]") or die "can't open";
	
	## open file hasil program
    open(HASIL,"> $_[3]") or die "can't open ";

	# total dokumen
	my $total_doc = 1000;
	
	# menampung kueri
	my $query = "juara sepakbola";
	
	# frekuensi kata pada suatu set dokumen
	my %dok = ();
		
	# jumlah dokumen yang mengandung kata i di koleksi
	my %koleksi = ();
	
	# untuk menampung daftar kata
	my @listwords = ();
	
	# untuk menampung daftar kueri
	my @listquery = ();
	
	# untuk menampung tf
	my %tf = ();
	
	# untuk menampung idf
	my %idf = ();
	
	# untuk menampung tf-idf
	my %tfidf = ();
	
	# untuk menampung w x d
	my %wxd = ();
	
	# untuk menampung w^2
	my %w2 = ();
	
	# untuk menampung d^2
	my %d2 = ();
	
	# menyimpan list query
	my @daftar = (split/\s+/,$query);
	foreach(@daftar) {
		push(@listquery, $_);
	}
	
	# membaca data dari file koleksi
	while(<WORDS>) {
		chomp;
        push(@listwords, $_)
	}
	
	#print Dumper \@listwords;
	
	my $docid = 1;
	my $idx = 0;
	my $totalWordEachDoc = 0;
	# membaca data dari dokumen
	while(<DOK>) {
		my @splitline = split;
		$totalWordEachDoc = 0;
		$idx = 0;
		foreach my $num(@splitline) {
			$totalWordEachDoc += $num;
			$dok{$docid}{$listwords[$idx]} = $num;
			$idx++;
		}
		$dok{$docid}{"totalWordEachDoc"} = $totalWordEachDoc;
		$docid++;
	}
	
	# membaca data dari koleksi
	while(<KOLEKSI>) {
		my @splitline = split;
		$idx = 0;
		foreach my $num(@splitline) {
			$koleksi{$listwords[$idx]} = $num;
			$idx++;
		}
	}
	
	printf HASIL ("2.c Soal i\n\n");
	printf HASIL ("Dokumen/Kata");
	# mencetak kata
	foreach(@listwords) {
		printf HASIL ("%13s", $_ );
	}
	
	printf HASIL "\n";
	
	# menghitung tf, idf, dan tf-idf
	foreach my $docid (sort keys %dok) {
		printf HASIL ("%12s", "D$docid");
		foreach my $kata (@listwords) {
			$tf{$docid}{$kata} = $dok{$docid}{$kata} / $dok{$docid}{"totalWordEachDoc"};
			$idf{$docid}{$kata} = log2($total_doc/$koleksi{$kata});
			$tfidf{$docid}{$kata} = $tf{$docid}{$kata}  * $idf{$docid}{$kata};
			$wxd{$docid}{$kata} = $idf{$docid}{$kata} * $tfidf{$docid}{$kata};
			$w2{$docid}{$kata} = $idf{$docid}{$kata} * $idf{$docid}{$kata};
			$d2{$docid}{$kata} = $tfidf{$docid}{$kata} * $tfidf{$docid}{$kata};
			printf HASIL ("%13.3f", $tfidf{$docid}{$kata});
		}
		printf HASIL ("\n");
	}

	# menghitung total
	foreach my $docid (sort keys %dok) {
		foreach my $kata (@listquery) {
			$wxd{$docid}{"total"} += $wxd{$docid}{$kata};
			$w2{$docid}{"total"} += $w2{$docid}{$kata};
			$d2{$docid}{"total"} += $d2{$docid}{$kata};
		}
	}
	
	# menampung maximum similarity
	my $max_similarity = -999999;
	
	# menampung minimum similarity
	my $min_similarity = 999999;
	
	printf HASIL "\n\n2.c Soal ii\n\n";
	printf HASIL "Kueri = $query\n\n";
	printf HASIL ".:: Jaccard Similarity ::.\n";
	
	# menghitung jaccard similarity setiap dokumen
	foreach my $docid (sort keys %dok) {
		$dok{$docid}{"jaccard"} = $wxd{$docid}{"total"} / 
		($w2{$docid}{"total"} + $d2{$docid}{"total"} - 
		$wxd{$docid}{"total"});
		printf HASIL ("Dokumen %d = %0.3f\n", $docid, $dok{$docid}{"jaccard"} );
		if($dok{$docid}{"jaccard"} > $max_similarity) {
			$max_similarity = $dok{$docid}{"jaccard"};
		} 
		
		if($dok{$docid}{"jaccard"} < $min_similarity) {
			$min_similarity = $dok{$docid}{"jaccard"};
		}
	}
	
	printf HASIL "\n";
	
	# Mencetak dokumen paling relevan 
	printf HASIL ("Dokumen yang paling relevan adalah \n");
	foreach my $docid (sort keys %dok) {
		if($dok{$docid}{"jaccard"} == $max_similarity) {
			printf HASIL ("Dokumen $docid\n");
		}
	}
	
	printf HASIL ("\n");
	
	# mencetak dokumen paling tidak relevan
	printf HASIL ("Dokumen yang paling tidak relevan adalah \n");
	foreach my $docid (sort keys %dok) {
		if($dok{$docid}{"jaccard"} ==  $min_similarity) {
			printf  HASIL ("Dokumen $docid\n");
		}
	}
	
	
	
	#print Dumper \@listquery;
	return %dok;
}


sub log2 {
    my $n = shift;
    return log($n)/log(2);
}