/****************************************************************************************************************************************
* Class Name  : Core_MDF_BankJSONParser_Test 
* Version     : 1.0 
* Created Date: 11-02-2018
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Varun Kumar                   11-02-2018                    Test class for Core_MDF_BankJSONParser
*****************************************************************************************************************************************/
@isTest
public class Core_MDF_BankJSONParser_Test {
	
	static testMethod void testParse() {
		String json = '['+
		'	{   '+
		'		\"SUPPL_HLD_PMT_IND\":\"N\",'+
		'		\"bnfcy_nm\":\"MIDERN COMPUTER INC\",'+
		'		\"intrmd_bank_ind\":\"N\",'+
		'		\"bnk_nbr\":\"121042882\",'+
		'		\"bnk_nm\":\"Wells Fargo Bank, National Association\",'+
		'		\"ap_vndr_nbr\":1000003272,'+
		'		\"DUNS_NBR\":\"181229154\",'+
		'		\"ctry_cd\":\"US\",'+
		'		\"swift_cd\":\"WFBIUS6SXXX\",'+
        '		\"suppl_nm\":\"Wells Fargo\"'+
		'	},'+
		'	{'+
		'		\"SUPPL_HLD_PMT_IND\":\"N\",'+
		'		\"bnfcy_nm\":\"LOWER COMPUTER INC\",'+
		'		\"intrmd_bank_ind\":\"N\",'+
		'		\"bnk_nbr\":\"12165442882\",'+
		'		\"bnk_nm\":\"Bank Of America\",'+
		'		\"ap_vndr_nbr\":1000003272,'+
		'		\"DUNS_NBR\":\"181259154\",'+
		'		\"ctry_cd\":\"US\",'+
		'		\"swift_cd\":\"WFB766SXXX\",'+
        '		\"suppl_nm\":\"Wells Fargo\"'+
		'	}'+
		']';
		List<Core_MDF_BankJSONParser> obj = Core_MDF_BankJSONParser.parse(json);
		System.assert(obj != null);
	}
}