package DDG::Goodie::CallingCodes;
# ABSTRACT: Matches country names to calling codes

use DDG::Goodie;
use Locale::Country qw/country2code code2country/;
use Telephony::CountryDialingCodes;

zci answer_type => "calling_codes";
zci is_cached => 1;

name        "CallingCodes";
description "Matches country names to international calling codes";
source      "https://en.wikipedia.org/wiki/List_of_country_calling_codes#Alphabetical_listing_by_country_or_region";
code_url    "https://github.com/duckduckgo/zeroclickinfo-spice/blob/master/lib/DDG/Goodie/CallingCodes.pm";
category    "geography";
topics      "travel", "geography";

primary_example_queries   "country code 55", "country code brazil";
secondary_example_queries "dialing code +55", "country calling code 55";

attribution github  => ["kablamo",            "Eric Johnson"],
            web     => ["http://kablamo.org", "Eric Johnson"];

triggers startend => "country code", "country calling code", "calling code",
                     "dialing code", "country dialing code";

Locale::Country::rename_country('ae' => 'the United Arab Emirates');
Locale::Country::rename_country('do' => 'the Dominican Republic');
Locale::Country::rename_country('gb' => 'the United Kingdom');
Locale::Country::rename_country('kp' => "the Republic of Korea");
Locale::Country::rename_country('kr' => "the Democratic People's Republic of Korea");
Locale::Country::rename_country('ky' => 'the Cayman Islands');
Locale::Country::rename_country('mp' => 'the Northern Mariana Islands');
Locale::Country::rename_country('ru' => 'the Russian Federation');
Locale::Country::rename_country('tw' => 'Taiwan');
Locale::Country::rename_country('us' => 'the United States');
Locale::Country::rename_country('vg' => 'the British Virgin Islands');
Locale::Country::rename_country('vi' => 'the US Virgin Islands');
Locale::Country::add_country_alias('Russian Federation'   => 'Russia');
Locale::Country::add_country_alias('Virgin Islands, U.S.' => 'US Virgin Islands');

handle remainder => sub {
    my $query = shift;

    my ($dialing_code, @countries);
   
    if ($query =~ /^\+?[\d|\s]+/) {
        ($dialing_code, @countries) = to_country($query);
    }
    elsif ($query =~ /^\w+/) {
        ($dialing_code, @countries) = to_calling_code($query);
    }

    return unless $dialing_code && @countries;

    my $answer = "+" . $dialing_code;
    $answer .= " is the international calling code for ";
    $answer .= list2string(@countries);

	return $answer;
};

sub list2string {
    my @countries = @_;
    my $string;

    if (scalar @countries == 1) {
        $string = $countries[0];
    }
    elsif (scalar @countries == 2) {
        $string = $countries[0] . " and " . $countries[1];
    }
    else {
        my $last = pop @countries;
        $string = join ', ', @countries;
        $string .= ", and " . $last;
    }

    return $string;
}

sub to_country {
    my $number = shift;

    # clean up
    $number =~ s/\+//;

    my $telephony     = Telephony::CountryDialingCodes->new;
    my @country_codes = $telephony->country_codes($number);
    my $dialing_code  = $telephony->extract_dialing_code($number);
    my @countries     = map { code2country($_) } @country_codes;

    return ($dialing_code, @countries);
}

sub to_calling_code {
    my $country = shift;

    # clean up
    $country =~ s/^for\s+//;
    $country =~ s/^the\s+//;

    my $country_code = country2code($country);

    # if we didn't find a country code, maybe $country is a country_code
    $country_code = $country unless $country_code;

    $country = code2country($country_code);

    my $telephony    = Telephony::CountryDialingCodes->new;
    my $dialing_code = $telephony->dialing_code($country_code);

    return ($dialing_code, $country);
}

1;
