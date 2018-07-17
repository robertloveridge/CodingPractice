<?php

/* Write a script that takes a list of email addresses on STDIN and outputs the 10 
 most common domains (including counts) */

/* an empty array, ready for our domains */
$domains = array();

/* emails from STDIN */
$emails = fopen( 'php://stdin', 'r' );

while( $line = fgets( $emails ) ) {
	$line = rtrim($line);
	$email = explode("@", $line);
	$domains[ $email[1] ]++;
}

fclose( $emails );

array_multisort($domains, SORT_DESC, $domains);
foreach  ($domains as $domain => $count){
	if ($count > 10) { break; }
	echo $domain . " => " . $count . "\n";
}
?>
