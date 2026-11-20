/**
 * @description Helper class containing IANA timezone mappings for countries and states.
 *              Provides default timezone for countries and state-specific timezones
 *              for countries with multiple time zones (USA, Canada, Australia, Brazil, etc.)
 * @author Aswin Selvaraj/Citrus
 * @date 2026-07-21
 */
public class CRM_EMB_TimezoneHelper {
    
    // Country code to default IANA timezone mapping
    private static Map<String, String> countryTimezones;
    
    // US State code to timezone mapping
    private static Map<String, String> usStateTimezones;
    
    // Canada Province code to timezone mapping
    private static Map<String, String> canadaTimezones;
    
    // Australia State code to timezone mapping
    private static Map<String, String> australiaTimezones;
    
    // Brazil State code to timezone mapping
    private static Map<String, String> brazilTimezones;
    
    // Mexico State code to timezone mapping
    private static Map<String, String> mexicoTimezones;
    
    // Russia Region code to timezone mapping
    private static Map<String, String> russiaTimezones;
    
    // Indonesia Province code to timezone mapping
    private static Map<String, String> indonesiaTimezones;
    
    /**
     * @description Initialize all timezone mappings
     */
    static {
        initCountryTimezones();
        initUSStateTimezones();
        initCanadaTimezones();
        initAustraliaTimezones();
        initBrazilTimezones();
        initMexicoTimezones();
        initRussiaTimezones();
        initIndonesiaTimezones();
    }
    
    /**
     * @description Get timezone for a given country and state code
     * @param countryCode ISO 3166-1 alpha-3 country code
     * @param stateCode State/Province code
     * @return IANA timezone identifier
     */
    public static String getTimezone(String countryCode, String stateCode) {
        String timezone = null;
        
        // Check for state-specific timezone first
        if (String.isNotBlank(stateCode)) {
            if (countryCode == 'USA' && usStateTimezones.containsKey(stateCode)) {
                timezone = usStateTimezones.get(stateCode);
            } else if (countryCode == 'CAN' && canadaTimezones.containsKey(stateCode)) {
                timezone = canadaTimezones.get(stateCode);
            } else if (countryCode == 'AUS' && australiaTimezones.containsKey(stateCode)) {
                timezone = australiaTimezones.get(stateCode);
            } else if (countryCode == 'BRA' && brazilTimezones.containsKey(stateCode)) {
                timezone = brazilTimezones.get(stateCode);
            } else if (countryCode == 'MEX' && mexicoTimezones.containsKey(stateCode)) {
                timezone = mexicoTimezones.get(stateCode);
            } else if (countryCode == 'RUS' && russiaTimezones.containsKey(stateCode)) {
                timezone = russiaTimezones.get(stateCode);
            } else if (countryCode == 'IDN' && indonesiaTimezones.containsKey(stateCode)) {
                timezone = indonesiaTimezones.get(stateCode);
            }
        }
        
        // Fall back to country default if no state-specific timezone
        if (String.isBlank(timezone) && countryTimezones.containsKey(countryCode)) {
            timezone = countryTimezones.get(countryCode);
        }
        
        // Default to UTC if nothing found
        return String.isNotBlank(timezone) ? timezone : 'UTC';
    }
    
    /**
     * @description Get default timezone for a country
     * @param countryCode ISO 3166-1 alpha-3 country code
     * @return IANA timezone identifier
     */
    public static String getCountryDefaultTimezone(String countryCode) {
        if (countryTimezones.containsKey(countryCode)) {
            return countryTimezones.get(countryCode);
        }
        return 'UTC';
    }
    
    /**
     * @description Initialize country to timezone mappings
     */
    private static void initCountryTimezones() {
        countryTimezones = new Map<String, String>();
        
        // A
        countryTimezones.put('AFG', 'Asia/Kabul');
        countryTimezones.put('ALA', 'Europe/Helsinki');
        countryTimezones.put('ALB', 'Europe/Tirane');
        countryTimezones.put('DZA', 'Africa/Algiers');
        countryTimezones.put('ASM', 'Pacific/Pago_Pago');
        countryTimezones.put('AND', 'Europe/Andorra');
        countryTimezones.put('AGO', 'Africa/Luanda');
        countryTimezones.put('AIA', 'America/Anguilla');
        countryTimezones.put('ATA', 'Antarctica/McMurdo');
        countryTimezones.put('ATG', 'America/Antigua');
        countryTimezones.put('ARG', 'America/Argentina/Buenos_Aires');
        countryTimezones.put('ARM', 'Asia/Yerevan');
        countryTimezones.put('ABW', 'America/Aruba');
        countryTimezones.put('AUS', 'Australia/Sydney');
        countryTimezones.put('AUT', 'Europe/Vienna');
        countryTimezones.put('AZE', 'Asia/Baku');
        
        // B
        countryTimezones.put('BHS', 'America/Nassau');
        countryTimezones.put('BHR', 'Asia/Bahrain');
        countryTimezones.put('BGD', 'Asia/Dhaka');
        countryTimezones.put('BRB', 'America/Barbados');
        countryTimezones.put('BLR', 'Europe/Minsk');
        countryTimezones.put('BEL', 'Europe/Brussels');
        countryTimezones.put('BLZ', 'America/Belize');
        countryTimezones.put('BEN', 'Africa/Porto-Novo');
        countryTimezones.put('BMU', 'Atlantic/Bermuda');
        countryTimezones.put('BTN', 'Asia/Thimphu');
        countryTimezones.put('BOL', 'America/La_Paz');
        countryTimezones.put('BES', 'America/Kralendijk');
        countryTimezones.put('BIH', 'Europe/Sarajevo');
        countryTimezones.put('BWA', 'Africa/Gaborone');
        countryTimezones.put('BVT', 'Antarctica/Troll');
        countryTimezones.put('BRA', 'America/Sao_Paulo');
        countryTimezones.put('IOT', 'Indian/Chagos');
        countryTimezones.put('VGB', 'America/Tortola');
        countryTimezones.put('BRN', 'Asia/Brunei');
        countryTimezones.put('BGR', 'Europe/Sofia');
        countryTimezones.put('BFA', 'Africa/Ouagadougou');
        countryTimezones.put('BDI', 'Africa/Bujumbura');
        
        // C
        countryTimezones.put('CAF', 'Africa/Bangui');
        countryTimezones.put('KHM', 'Asia/Phnom_Penh');
        countryTimezones.put('CMR', 'Africa/Douala');
        countryTimezones.put('CAN', 'America/Toronto');
        countryTimezones.put('CPV', 'Atlantic/Cape_Verde');
        countryTimezones.put('CYM', 'America/Cayman');
        countryTimezones.put('TCD', 'Africa/Ndjamena');
        countryTimezones.put('CHL', 'America/Santiago');
        countryTimezones.put('CHN', 'Asia/Shanghai');
        countryTimezones.put('CXR', 'Indian/Christmas');
        countryTimezones.put('CCK', 'Indian/Cocos');
        countryTimezones.put('COL', 'America/Bogota');
        countryTimezones.put('COM', 'Indian/Comoro');
        countryTimezones.put('COG', 'Africa/Brazzaville');
        countryTimezones.put('COK', 'Pacific/Rarotonga');
        countryTimezones.put('CRI', 'America/Costa_Rica');
        countryTimezones.put('CIV', 'Africa/Abidjan');
        countryTimezones.put('HRV', 'Europe/Zagreb');
        countryTimezones.put('CUB', 'America/Havana');
        countryTimezones.put('CUW', 'America/Curacao');
        countryTimezones.put('CYP', 'Asia/Nicosia');
        countryTimezones.put('CZE', 'Europe/Prague');
        countryTimezones.put('COD', 'Africa/Kinshasa');
        
        // D
        countryTimezones.put('DNK', 'Europe/Copenhagen');
        countryTimezones.put('DJI', 'Africa/Djibouti');
        countryTimezones.put('DMA', 'America/Dominica');
        countryTimezones.put('DOM', 'America/Santo_Domingo');
        
        // E
        countryTimezones.put('ECU', 'America/Guayaquil');
        countryTimezones.put('EGY', 'Africa/Cairo');
        countryTimezones.put('SLV', 'America/El_Salvador');
        countryTimezones.put('GNQ', 'Africa/Malabo');
        countryTimezones.put('ERI', 'Africa/Asmara');
        countryTimezones.put('EST', 'Europe/Tallinn');
        countryTimezones.put('SWZ', 'Africa/Mbabane');
        countryTimezones.put('ETH', 'Africa/Addis_Ababa');
        
        // F
        countryTimezones.put('FLK', 'Atlantic/Stanley');
        countryTimezones.put('FRO', 'Atlantic/Faroe');
        countryTimezones.put('FJI', 'Pacific/Fiji');
        countryTimezones.put('FIN', 'Europe/Helsinki');
        countryTimezones.put('FRA', 'Europe/Paris');
        countryTimezones.put('GUF', 'America/Cayenne');
        countryTimezones.put('PYF', 'Pacific/Tahiti');
        countryTimezones.put('ATF', 'Indian/Kerguelen');
        
        // G
        countryTimezones.put('GAB', 'Africa/Libreville');
        countryTimezones.put('GMB', 'Africa/Banjul');
        countryTimezones.put('GEO', 'Asia/Tbilisi');
        countryTimezones.put('DEU', 'Europe/Berlin');
        countryTimezones.put('GHA', 'Africa/Accra');
        countryTimezones.put('GIB', 'Europe/Gibraltar');
        countryTimezones.put('GRC', 'Europe/Athens');
        countryTimezones.put('GRL', 'America/Godthab');
        countryTimezones.put('GRD', 'America/Grenada');
        countryTimezones.put('GLP', 'America/Guadeloupe');
        countryTimezones.put('GUM', 'Pacific/Guam');
        countryTimezones.put('GTM', 'America/Guatemala');
        countryTimezones.put('GGY', 'Europe/Guernsey');
        countryTimezones.put('GIN', 'Africa/Conakry');
        countryTimezones.put('GNB', 'Africa/Bissau');
        countryTimezones.put('GUY', 'America/Guyana');
        
        // H
        countryTimezones.put('HTI', 'America/Port-au-Prince');
        countryTimezones.put('HMD', 'Indian/Kerguelen');
        countryTimezones.put('HND', 'America/Tegucigalpa');
        countryTimezones.put('HKG', 'Asia/Hong_Kong');
        countryTimezones.put('HUN', 'Europe/Budapest');
        
        // I
        countryTimezones.put('ISL', 'Atlantic/Reykjavik');
        countryTimezones.put('IND', 'Asia/Kolkata');
        countryTimezones.put('IDN', 'Asia/Jakarta');
        countryTimezones.put('IRN', 'Asia/Tehran');
        countryTimezones.put('IRQ', 'Asia/Baghdad');
        countryTimezones.put('IRL', 'Europe/Dublin');
        countryTimezones.put('IMN', 'Europe/Isle_of_Man');
        countryTimezones.put('ISR', 'Asia/Jerusalem');
        countryTimezones.put('ITA', 'Europe/Rome');
        
        // J
        countryTimezones.put('JAM', 'America/Jamaica');
        countryTimezones.put('JPN', 'Asia/Tokyo');
        countryTimezones.put('JEY', 'Europe/Jersey');
        countryTimezones.put('JOR', 'Asia/Amman');
        
        // K
        countryTimezones.put('KAZ', 'Asia/Almaty');
        countryTimezones.put('KEN', 'Africa/Nairobi');
        countryTimezones.put('KIR', 'Pacific/Tarawa');
        countryTimezones.put('KWT', 'Asia/Kuwait');
        countryTimezones.put('KGZ', 'Asia/Bishkek');
        
        // L
        countryTimezones.put('LAO', 'Asia/Vientiane');
        countryTimezones.put('LVA', 'Europe/Riga');
        countryTimezones.put('LBN', 'Asia/Beirut');
        countryTimezones.put('LSO', 'Africa/Maseru');
        countryTimezones.put('LBR', 'Africa/Monrovia');
        countryTimezones.put('LBY', 'Africa/Tripoli');
        countryTimezones.put('LIE', 'Europe/Vaduz');
        countryTimezones.put('LTU', 'Europe/Vilnius');
        countryTimezones.put('LUX', 'Europe/Luxembourg');
        
        // M
        countryTimezones.put('MAC', 'Asia/Macau');
        countryTimezones.put('MDG', 'Indian/Antananarivo');
        countryTimezones.put('MWI', 'Africa/Blantyre');
        countryTimezones.put('MYS', 'Asia/Kuala_Lumpur');
        countryTimezones.put('MDV', 'Indian/Maldives');
        countryTimezones.put('MLI', 'Africa/Bamako');
        countryTimezones.put('MLT', 'Europe/Malta');
        countryTimezones.put('MHL', 'Pacific/Majuro');
        countryTimezones.put('MTQ', 'America/Martinique');
        countryTimezones.put('MRT', 'Africa/Nouakchott');
        countryTimezones.put('MUS', 'Indian/Mauritius');
        countryTimezones.put('MYT', 'Indian/Mayotte');
        countryTimezones.put('MEX', 'America/Mexico_City');
        countryTimezones.put('FSM', 'Pacific/Pohnpei');
        countryTimezones.put('UMI', 'Pacific/Midway');
        countryTimezones.put('MDA', 'Europe/Chisinau');
        countryTimezones.put('MCO', 'Europe/Monaco');
        countryTimezones.put('MNG', 'Asia/Ulaanbaatar');
        countryTimezones.put('MNE', 'Europe/Podgorica');
        countryTimezones.put('MSR', 'America/Montserrat');
        countryTimezones.put('MAR', 'Africa/Casablanca');
        countryTimezones.put('MOZ', 'Africa/Maputo');
        countryTimezones.put('MMR', 'Asia/Yangon');
        countryTimezones.put('MNP', 'Pacific/Saipan');
        
        // N
        countryTimezones.put('NAM', 'Africa/Windhoek');
        countryTimezones.put('NRU', 'Pacific/Nauru');
        countryTimezones.put('NPL', 'Asia/Kathmandu');
        countryTimezones.put('NLD', 'Europe/Amsterdam');
        countryTimezones.put('NCL', 'Pacific/Noumea');
        countryTimezones.put('NZL', 'Pacific/Auckland');
        countryTimezones.put('NIC', 'America/Managua');
        countryTimezones.put('NER', 'Africa/Niamey');
        countryTimezones.put('NGA', 'Africa/Lagos');
        countryTimezones.put('NIU', 'Pacific/Niue');
        countryTimezones.put('NFK', 'Pacific/Norfolk');
        countryTimezones.put('PRK', 'Asia/Pyongyang');
        countryTimezones.put('MKD', 'Europe/Skopje');
        countryTimezones.put('NOR', 'Europe/Oslo');
        
        // O
        countryTimezones.put('OMN', 'Asia/Muscat');
        
        // P
        countryTimezones.put('PAK', 'Asia/Karachi');
        countryTimezones.put('PLW', 'Pacific/Palau');
        countryTimezones.put('PSE', 'Asia/Gaza');
        countryTimezones.put('PAN', 'America/Panama');
        countryTimezones.put('PNG', 'Pacific/Port_Moresby');
        countryTimezones.put('PRY', 'America/Asuncion');
        countryTimezones.put('PER', 'America/Lima');
        countryTimezones.put('PHL', 'Asia/Manila');
        countryTimezones.put('PCN', 'Pacific/Pitcairn');
        countryTimezones.put('POL', 'Europe/Warsaw');
        countryTimezones.put('PRT', 'Europe/Lisbon');
        countryTimezones.put('PRI', 'America/Puerto_Rico');
        
        // Q
        countryTimezones.put('QAT', 'Asia/Qatar');
        
        // R
        countryTimezones.put('REU', 'Indian/Reunion');
        countryTimezones.put('ROU', 'Europe/Bucharest');
        countryTimezones.put('RUS', 'Europe/Moscow');
        countryTimezones.put('RWA', 'Africa/Kigali');
        
        // S
        countryTimezones.put('SGS', 'Atlantic/South_Georgia');
        countryTimezones.put('STP', 'Africa/Sao_Tome');
        countryTimezones.put('LCA', 'America/St_Lucia');
        countryTimezones.put('MAF', 'America/Marigot');
        countryTimezones.put('SPM', 'America/Miquelon');
        countryTimezones.put('WSM', 'Pacific/Apia');
        countryTimezones.put('SMR', 'Europe/San_Marino');
        countryTimezones.put('SAU', 'Asia/Riyadh');
        countryTimezones.put('SEN', 'Africa/Dakar');
        countryTimezones.put('SRB', 'Europe/Belgrade');
        countryTimezones.put('SYC', 'Indian/Mahe');
        countryTimezones.put('SLE', 'Africa/Freetown');
        countryTimezones.put('SGP', 'Asia/Singapore');
        countryTimezones.put('SXM', 'America/Lower_Princes');
        countryTimezones.put('SVK', 'Europe/Bratislava');
        countryTimezones.put('SVN', 'Europe/Ljubljana');
        countryTimezones.put('SLB', 'Pacific/Guadalcanal');
        countryTimezones.put('SOM', 'Africa/Mogadishu');
        countryTimezones.put('ZAF', 'Africa/Johannesburg');
        countryTimezones.put('KOR', 'Asia/Seoul');
        countryTimezones.put('SSD', 'Africa/Juba');
        countryTimezones.put('ESP', 'Europe/Madrid');
        countryTimezones.put('LKA', 'Asia/Colombo');
        countryTimezones.put('BLM', 'America/St_Barthelemy');
        countryTimezones.put('SHN', 'Atlantic/St_Helena');
        countryTimezones.put('VCT', 'America/St_Vincent');
        countryTimezones.put('KNA', 'America/St_Kitts');
        countryTimezones.put('SDN', 'Africa/Khartoum');
        countryTimezones.put('SUR', 'America/Paramaribo');
        countryTimezones.put('SJM', 'Arctic/Longyearbyen');
        countryTimezones.put('SWE', 'Europe/Stockholm');
        countryTimezones.put('CHE', 'Europe/Zurich');
        countryTimezones.put('SYR', 'Asia/Damascus');
        
        // T
        countryTimezones.put('TWN', 'Asia/Taipei');
        countryTimezones.put('TJK', 'Asia/Dushanbe');
        countryTimezones.put('TZA', 'Africa/Dar_es_Salaam');
        countryTimezones.put('THA', 'Asia/Bangkok');
        countryTimezones.put('TLS', 'Asia/Dili');
        countryTimezones.put('TGO', 'Africa/Lome');
        countryTimezones.put('TKL', 'Pacific/Fakaofo');
        countryTimezones.put('TON', 'Pacific/Tongatapu');
        countryTimezones.put('TTO', 'America/Port_of_Spain');
        countryTimezones.put('TUN', 'Africa/Tunis');
        countryTimezones.put('TUR', 'Europe/Istanbul');
        countryTimezones.put('TKM', 'Asia/Ashgabat');
        countryTimezones.put('TCA', 'America/Grand_Turk');
        countryTimezones.put('TUV', 'Pacific/Funafuti');
        
        // U
        countryTimezones.put('UGA', 'Africa/Kampala');
        countryTimezones.put('UKR', 'Europe/Kiev');
        countryTimezones.put('GBR', 'Europe/London');
        countryTimezones.put('USA', 'America/New_York');
        countryTimezones.put('URY', 'America/Montevideo');
        countryTimezones.put('ARE', 'Asia/Dubai');
        countryTimezones.put('UZB', 'Asia/Tashkent');
        
        // V
        countryTimezones.put('VUT', 'Pacific/Efate');
        countryTimezones.put('VAT', 'Europe/Vatican');
        countryTimezones.put('VEN', 'America/Caracas');
        countryTimezones.put('VNM', 'Asia/Ho_Chi_Minh');
        countryTimezones.put('VIR', 'America/St_Thomas');
        
        // W
        countryTimezones.put('WLF', 'Pacific/Wallis');
        countryTimezones.put('ESH', 'Africa/El_Aaiun');
        
        // Y
        countryTimezones.put('YEM', 'Asia/Aden');
        
        // Z
        countryTimezones.put('ZMB', 'Africa/Lusaka');
        countryTimezones.put('ZWE', 'Africa/Harare');
    }
    
    /**
     * @description Initialize US state to timezone mappings
     */
    private static void initUSStateTimezones() {
        usStateTimezones = new Map<String, String>();
        usStateTimezones.put('AL', 'America/Chicago');
        usStateTimezones.put('AK', 'America/Anchorage');
        usStateTimezones.put('AZ', 'America/Phoenix');
        usStateTimezones.put('AR', 'America/Chicago');
        usStateTimezones.put('CA', 'America/Los_Angeles');
        usStateTimezones.put('CO', 'America/Denver');
        usStateTimezones.put('CT', 'America/New_York');
        usStateTimezones.put('DE', 'America/New_York');
        usStateTimezones.put('DC', 'America/New_York');
        usStateTimezones.put('FL', 'America/New_York');
        usStateTimezones.put('GA', 'America/New_York');
        usStateTimezones.put('HI', 'Pacific/Honolulu');
        usStateTimezones.put('ID', 'America/Boise');
        usStateTimezones.put('IL', 'America/Chicago');
        usStateTimezones.put('IN', 'America/Indiana/Indianapolis');
        usStateTimezones.put('IA', 'America/Chicago');
        usStateTimezones.put('KS', 'America/Chicago');
        usStateTimezones.put('KY', 'America/New_York');
        usStateTimezones.put('LA', 'America/Chicago');
        usStateTimezones.put('ME', 'America/New_York');
        usStateTimezones.put('MD', 'America/New_York');
        usStateTimezones.put('MA', 'America/New_York');
        usStateTimezones.put('MI', 'America/Detroit');
        usStateTimezones.put('MN', 'America/Chicago');
        usStateTimezones.put('MS', 'America/Chicago');
        usStateTimezones.put('MO', 'America/Chicago');
        usStateTimezones.put('MT', 'America/Denver');
        usStateTimezones.put('NE', 'America/Chicago');
        usStateTimezones.put('NV', 'America/Los_Angeles');
        usStateTimezones.put('NH', 'America/New_York');
        usStateTimezones.put('NJ', 'America/New_York');
        usStateTimezones.put('NM', 'America/Denver');
        usStateTimezones.put('NY', 'America/New_York');
        usStateTimezones.put('NC', 'America/New_York');
        usStateTimezones.put('ND', 'America/Chicago');
        usStateTimezones.put('OH', 'America/New_York');
        usStateTimezones.put('OK', 'America/Chicago');
        usStateTimezones.put('OR', 'America/Los_Angeles');
        usStateTimezones.put('PA', 'America/New_York');
        usStateTimezones.put('RI', 'America/New_York');
        usStateTimezones.put('SC', 'America/New_York');
        usStateTimezones.put('SD', 'America/Chicago');
        usStateTimezones.put('TN', 'America/Chicago');
        usStateTimezones.put('TX', 'America/Chicago');
        usStateTimezones.put('UT', 'America/Denver');
        usStateTimezones.put('VT', 'America/New_York');
        usStateTimezones.put('VA', 'America/New_York');
        usStateTimezones.put('WA', 'America/Los_Angeles');
        usStateTimezones.put('WV', 'America/New_York');
        usStateTimezones.put('WI', 'America/Chicago');
        usStateTimezones.put('WY', 'America/Denver');
        // US Territories
        usStateTimezones.put('AS', 'Pacific/Pago_Pago');
        usStateTimezones.put('GU', 'Pacific/Guam');
        usStateTimezones.put('MP', 'Pacific/Guam');
        usStateTimezones.put('PR', 'America/Puerto_Rico');
        usStateTimezones.put('VI', 'America/St_Thomas');
        usStateTimezones.put('UM', 'Pacific/Midway');
    }
    
    /**
     * @description Initialize Canada province to timezone mappings
     */
    private static void initCanadaTimezones() {
        canadaTimezones = new Map<String, String>();
        canadaTimezones.put('AB', 'America/Edmonton');
        canadaTimezones.put('BC', 'America/Vancouver');
        canadaTimezones.put('MB', 'America/Winnipeg');
        canadaTimezones.put('NB', 'America/Moncton');
        canadaTimezones.put('NL', 'America/St_Johns');
        canadaTimezones.put('NS', 'America/Halifax');
        canadaTimezones.put('NT', 'America/Yellowknife');
        canadaTimezones.put('NU', 'America/Iqaluit');
        canadaTimezones.put('ON', 'America/Toronto');
        canadaTimezones.put('PE', 'America/Halifax');
        canadaTimezones.put('QC', 'America/Montreal');
        canadaTimezones.put('SK', 'America/Regina');
        canadaTimezones.put('YT', 'America/Whitehorse');
    }
    
    /**
     * @description Initialize Australia state to timezone mappings
     */
    private static void initAustraliaTimezones() {
        australiaTimezones = new Map<String, String>();
        australiaTimezones.put('ACT', 'Australia/Sydney');
        australiaTimezones.put('NSW', 'Australia/Sydney');
        australiaTimezones.put('NT', 'Australia/Darwin');
        australiaTimezones.put('QLD', 'Australia/Brisbane');
        australiaTimezones.put('SA', 'Australia/Adelaide');
        australiaTimezones.put('TAS', 'Australia/Hobart');
        australiaTimezones.put('VIC', 'Australia/Melbourne');
        australiaTimezones.put('WA', 'Australia/Perth');
    }
    
    /**
     * @description Initialize Brazil state to timezone mappings
     */
    private static void initBrazilTimezones() {
        brazilTimezones = new Map<String, String>();
        brazilTimezones.put('AC', 'America/Rio_Branco');
        brazilTimezones.put('AL', 'America/Maceio');
        brazilTimezones.put('AP', 'America/Belem');
        brazilTimezones.put('AM', 'America/Manaus');
        brazilTimezones.put('BA', 'America/Bahia');
        brazilTimezones.put('CE', 'America/Fortaleza');
        brazilTimezones.put('DF', 'America/Sao_Paulo');
        brazilTimezones.put('ES', 'America/Sao_Paulo');
        brazilTimezones.put('GO', 'America/Sao_Paulo');
        brazilTimezones.put('MA', 'America/Fortaleza');
        brazilTimezones.put('MT', 'America/Cuiaba');
        brazilTimezones.put('MS', 'America/Campo_Grande');
        brazilTimezones.put('MG', 'America/Sao_Paulo');
        brazilTimezones.put('PA', 'America/Belem');
        brazilTimezones.put('PB', 'America/Fortaleza');
        brazilTimezones.put('PR', 'America/Sao_Paulo');
        brazilTimezones.put('PE', 'America/Recife');
        brazilTimezones.put('PI', 'America/Fortaleza');
        brazilTimezones.put('RJ', 'America/Sao_Paulo');
        brazilTimezones.put('RN', 'America/Fortaleza');
        brazilTimezones.put('RS', 'America/Sao_Paulo');
        brazilTimezones.put('RO', 'America/Porto_Velho');
        brazilTimezones.put('RR', 'America/Boa_Vista');
        brazilTimezones.put('SC', 'America/Sao_Paulo');
        brazilTimezones.put('SP', 'America/Sao_Paulo');
        brazilTimezones.put('SE', 'America/Maceio');
        brazilTimezones.put('TO', 'America/Araguaina');
    }
    
    /**
     * @description Initialize Mexico state to timezone mappings
     */
    private static void initMexicoTimezones() {
        mexicoTimezones = new Map<String, String>();
        mexicoTimezones.put('AGU', 'America/Mexico_City');
        mexicoTimezones.put('BCN', 'America/Tijuana');
        mexicoTimezones.put('BCS', 'America/Mazatlan');
        mexicoTimezones.put('CAM', 'America/Merida');
        mexicoTimezones.put('CHP', 'America/Mexico_City');
        mexicoTimezones.put('CHH', 'America/Chihuahua');
        mexicoTimezones.put('CMX', 'America/Mexico_City');
        mexicoTimezones.put('COA', 'America/Monterrey');
        mexicoTimezones.put('COL', 'America/Mexico_City');
        mexicoTimezones.put('DUR', 'America/Monterrey');
        mexicoTimezones.put('GUA', 'America/Mexico_City');
        mexicoTimezones.put('GRO', 'America/Mexico_City');
        mexicoTimezones.put('HID', 'America/Mexico_City');
        mexicoTimezones.put('JAL', 'America/Mexico_City');
        mexicoTimezones.put('MEX', 'America/Mexico_City');
        mexicoTimezones.put('MIC', 'America/Mexico_City');
        mexicoTimezones.put('MOR', 'America/Mexico_City');
        mexicoTimezones.put('NAY', 'America/Mazatlan');
        mexicoTimezones.put('NLE', 'America/Monterrey');
        mexicoTimezones.put('OAX', 'America/Mexico_City');
        mexicoTimezones.put('PUE', 'America/Mexico_City');
        mexicoTimezones.put('QUE', 'America/Mexico_City');
        mexicoTimezones.put('ROO', 'America/Cancun');
        mexicoTimezones.put('SLP', 'America/Mexico_City');
        mexicoTimezones.put('SIN', 'America/Mazatlan');
        mexicoTimezones.put('SON', 'America/Hermosillo');
        mexicoTimezones.put('TAB', 'America/Mexico_City');
        mexicoTimezones.put('TAM', 'America/Monterrey');
        mexicoTimezones.put('TLA', 'America/Mexico_City');
        mexicoTimezones.put('VER', 'America/Mexico_City');
        mexicoTimezones.put('YUC', 'America/Merida');
        mexicoTimezones.put('ZAC', 'America/Mexico_City');
    }
    
    /**
     * @description Initialize Russia region to timezone mappings
     */
    private static void initRussiaTimezones() {
        russiaTimezones = new Map<String, String>();
        russiaTimezones.put('MOW', 'Europe/Moscow');
        russiaTimezones.put('SPE', 'Europe/Moscow');
        russiaTimezones.put('KGD', 'Europe/Kaliningrad');
        russiaTimezones.put('SVE', 'Asia/Yekaterinburg');
        russiaTimezones.put('OMS', 'Asia/Omsk');
        russiaTimezones.put('NVS', 'Asia/Novosibirsk');
        russiaTimezones.put('KYA', 'Asia/Krasnoyarsk');
        russiaTimezones.put('IRK', 'Asia/Irkutsk');
        russiaTimezones.put('YAK', 'Asia/Yakutsk');
        russiaTimezones.put('PRI', 'Asia/Vladivostok');
        russiaTimezones.put('MAG', 'Asia/Magadan');
        russiaTimezones.put('KAM', 'Asia/Kamchatka');
        russiaTimezones.put('SAK', 'Asia/Sakhalin');
        russiaTimezones.put('CHU', 'Asia/Anadyr');
    }
    
    /**
     * @description Initialize Indonesia province to timezone mappings
     */
    private static void initIndonesiaTimezones() {
        indonesiaTimezones = new Map<String, String>();
        // Western Indonesia Time (WIB) - UTC+7
        indonesiaTimezones.put('AC', 'Asia/Jakarta');
        indonesiaTimezones.put('BB', 'Asia/Jakarta');
        indonesiaTimezones.put('BE', 'Asia/Jakarta');
        indonesiaTimezones.put('BT', 'Asia/Jakarta');
        indonesiaTimezones.put('JA', 'Asia/Jakarta');
        indonesiaTimezones.put('JB', 'Asia/Jakarta');
        indonesiaTimezones.put('JI', 'Asia/Jakarta');
        indonesiaTimezones.put('JK', 'Asia/Jakarta');
        indonesiaTimezones.put('JT', 'Asia/Jakarta');
        indonesiaTimezones.put('KR', 'Asia/Jakarta');
        indonesiaTimezones.put('LA', 'Asia/Jakarta');
        indonesiaTimezones.put('RI', 'Asia/Jakarta');
        indonesiaTimezones.put('SB', 'Asia/Jakarta');
        indonesiaTimezones.put('SS', 'Asia/Jakarta');
        indonesiaTimezones.put('SU', 'Asia/Jakarta');
        indonesiaTimezones.put('YO', 'Asia/Jakarta');
        // Central Indonesia Time (WITA) - UTC+8
        indonesiaTimezones.put('BA', 'Asia/Makassar');
        indonesiaTimezones.put('GO', 'Asia/Makassar');
        indonesiaTimezones.put('KI', 'Asia/Makassar');
        indonesiaTimezones.put('KS', 'Asia/Makassar');
        indonesiaTimezones.put('KT', 'Asia/Makassar');
        indonesiaTimezones.put('KU', 'Asia/Makassar');
        indonesiaTimezones.put('MU', 'Asia/Makassar');
        indonesiaTimezones.put('NB', 'Asia/Makassar');
        indonesiaTimezones.put('NT', 'Asia/Makassar');
        indonesiaTimezones.put('SA', 'Asia/Makassar');
        indonesiaTimezones.put('SG', 'Asia/Makassar');
        indonesiaTimezones.put('SN', 'Asia/Makassar');
        indonesiaTimezones.put('SR', 'Asia/Makassar');
        indonesiaTimezones.put('ST', 'Asia/Makassar');
        // West Kalimantan uses Pontianak
        indonesiaTimezones.put('KB', 'Asia/Pontianak');
        // Eastern Indonesia Time (WIT) - UTC+9
        indonesiaTimezones.put('MA', 'Asia/Jayapura');
        indonesiaTimezones.put('PA', 'Asia/Jayapura');
        indonesiaTimezones.put('PB', 'Asia/Jayapura');
    }
}