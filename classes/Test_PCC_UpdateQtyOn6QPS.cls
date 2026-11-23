public without sharing class Test_PCC_UpdateQtyOn6QPS { 
    
    public static void updateQtyOn6QPS(List<PCC_Rebate_Claim_Line_Item__c> rebateClaimLIList)
	{
		List<Core_Log_Entry__c> logEntries = new List<Core_Log_Entry__c>();
        try{
			Map<Id, Integer> OLIWithQtrCnt = new Map<Id, Integer>();
            Map<Id,Map<String, Decimal>> QLwithQtrQty = new Map<Id,Map<String, Decimal>>();
			Map<String, Decimal> QtrWithQty = new Map<String, Decimal>();
            Map<Id,Map<String, Decimal>> QLwithQtrQtyMap = new Map<Id,Map<String, Decimal>>();
            Map<Id,Map<String, Decimal>> QLwithQtrApprovedQty = new Map<Id,Map<String, Decimal>>();
            Map<String, Decimal> QtrWithApprovedQty = new Map<String, Decimal>();
            
            Map<Id,Map<String, Decimal>> QLwithQtrwithRemainingApprovedQty = new Map<Id,Map<String, Decimal>>();
            Map<String, Decimal> QtrwithRemainingApprovedQty = new Map<String, Decimal>();
            
            Map<Id,Map<String, Decimal>> QLwithQtrRemainingQty = new Map<Id,Map<String, Decimal>>();
            Map<String, Decimal> QtrWithRemainingQty = new Map<String, Decimal>();
			
			Map<Id, List<rebateClaimItemQuoteLineDetails>> QLWrp = new Map<Id, List<rebateClaimItemQuoteLineDetails>>();
			rebateClaimItemQuoteLineDetails qlWrapper = new rebateClaimItemQuoteLineDetails();
			
			Map<String, Decimal> PreviousQtrMap = new Map<String, Decimal>();
			Map<String, Decimal> FutureQtrMap = new Map<String, Decimal>();
			Map<String, Date> QuarterEndDateMap = new Map<String, Date>();
			
			for(PCC_Rebate_Claim_Line_Item__c rcl : rebateClaimLIList)
			{
				String Qrtr = Core_FC_ProductSchedule_Ctrl.getQuarter(rcl.PCC_Invoice_Date__c);
				qlWrapper = new rebateClaimItemQuoteLineDetails();
				qlWrapper.RCLIStatus = rcl.PCC_Status__c;
				qlWrapper.RCLIQty = rcl.PCC_Quantity__c;
				qlWrapper.RCLIQtr = Qrtr;          
                qlWrapper.RCLIQL = rcl.PCC_Quote_Line_Number__c;
                
				if (!QLWrp.containsKey(rcl.PCC_Quote_Line_Number__c)) 
				{
					QLWrp.put(rcl.PCC_Quote_Line_Number__c, new List<rebateClaimItemQuoteLineDetails>());
				}
				QLWrp.get(rcl.PCC_Quote_Line_Number__c).add(qlWrapper);
			}
            
			List<Core_Opp_FC_Prod_Schedule__c> fcList = [select id, name, Core_FC_Opportunity_Product__c,Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c,Core_Opp_FC_Quarter__c,Core_Opp_FC_Quantity__c, Core_FC_Approved_Claim_Quantity_nbr__c, Core_FC_Submitted_Claim_Quantity_nbr__c,Core_FC_Remaining_Claim_Quantity_nbr__c from Core_Opp_FC_Prod_Schedule__c where Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c IN : QLWrp.keySet()];
			for (Core_Opp_FC_Prod_Schedule__c fcRecord : fcList)
			{
                                 if (!OLIWithQtrCnt.containsKey(fcRecord.Core_FC_Opportunity_Product__c)) {
                                        OLIWithQtrCnt.put(fcRecord.Core_FC_Opportunity_Product__c, 0);
                                    }
                                    
                                    Integer qtrSizeForFCRecord = OLIWithQtrCnt.get(fcRecord.Core_FC_Opportunity_Product__c);
                                    qtrSizeForFCRecord++;
                
                                    OLIWithQtrCnt.put(fcRecord.Core_FC_Opportunity_Product__c, qtrSizeForFCRecord);
                                    
                                    fcRecord.Core_FC_Submitted_Claim_Quantity_nbr__c = fcRecord.Core_FC_Submitted_Claim_Quantity_nbr__c == null ? 0 :fcRecord.Core_FC_Submitted_Claim_Quantity_nbr__c;
                                    fcRecord.Core_FC_Approved_Claim_Quantity_nbr__c = fcRecord.Core_FC_Approved_Claim_Quantity_nbr__c == null ? 0 :fcRecord.Core_FC_Approved_Claim_Quantity_nbr__c;
                                    
                                    if (!QLwithQtrQty.containsKey(fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c)) {
                                        QLwithQtrQty.put(fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c, new Map<String, Decimal>());
                                    }
                                    
                                    QtrWithQty = QLwithQtrQty.get(fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c);
                                    
                                    if (!QtrWithQty.containsKey(fcRecord.Core_Opp_FC_Quarter__c)) {
                                        QtrWithQty.put(fcRecord.Core_Opp_FC_Quarter__c, 0);
                                                       //fcRecord.Core_Opp_FC_Quantity__c);
                                    }
                                    Decimal currentQty = QtrWithQty.get(fcRecord.Core_Opp_FC_Quarter__c);
                                    QtrWithQty.put(fcRecord.Core_Opp_FC_Quarter__c, currentQty + fcRecord.Core_Opp_FC_Quantity__c);
                                    
                                    QLwithQtrQty.put(fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c,QtrWithQty); 
                
                					if (!QLwithQtrApprovedQty.containsKey(fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c)) {
                                        QLwithQtrApprovedQty.put(fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c, new Map<String, Decimal>());
                                    }
                                    
                                    QtrWithApprovedQty = QLwithQtrApprovedQty.get(fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c);
                                    
                                    if (!QtrWithApprovedQty.containsKey(fcRecord.Core_Opp_FC_Quarter__c)) {
                                        QtrWithApprovedQty.put(fcRecord.Core_Opp_FC_Quarter__c, 0);
                                    }
                                    Decimal currentQty2 = QtrWithApprovedQty.get(fcRecord.Core_Opp_FC_Quarter__c);
                                    QtrWithApprovedQty.put(fcRecord.Core_Opp_FC_Quarter__c, currentQty2 + fcRecord.Core_FC_Approved_Claim_Quantity_nbr__c);
                                    
                                    QLwithQtrApprovedQty.put(fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c,QtrWithApprovedQty); 
                
                					if (!QLwithQtrRemainingQty.containsKey(fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c)) {
                                        QLwithQtrRemainingQty.put(fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c, new Map<String, Decimal>());
                                    }
                                    
                                    QtrWithRemainingQty = QLwithQtrRemainingQty.get(fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c);
                                    
                                    if (!QtrWithRemainingQty.containsKey(fcRecord.Core_Opp_FC_Quarter__c)) {
                                        QtrWithRemainingQty.put(fcRecord.Core_Opp_FC_Quarter__c, 0);
                                    }
                                    Decimal currentQty3 = QtrWithRemainingQty.get(fcRecord.Core_Opp_FC_Quarter__c);
                                    QtrWithRemainingQty.put(fcRecord.Core_Opp_FC_Quarter__c, currentQty3 + fcRecord.Core_FC_Remaining_Claim_Quantity_nbr__c);
                                    
                                    QLwithQtrRemainingQty.put(fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c,QtrWithRemainingQty); 
                
                					//New
                					if (!QLwithQtrwithRemainingApprovedQty.containsKey(fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c)) {
                                        QLwithQtrwithRemainingApprovedQty.put(fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c, new Map<String, Decimal>());
                                    }
                                    
                                    QtrwithRemainingApprovedQty = QLwithQtrwithRemainingApprovedQty.get(fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c);
                                    
                                    if (!QtrwithRemainingApprovedQty.containsKey(fcRecord.Core_Opp_FC_Quarter__c)) {
                                        QtrwithRemainingApprovedQty.put(fcRecord.Core_Opp_FC_Quarter__c, 0);
                                    }
                                    Decimal currentQty4 = QtrwithRemainingApprovedQty.get(fcRecord.Core_Opp_FC_Quarter__c);
                                    QtrwithRemainingApprovedQty.put(fcRecord.Core_Opp_FC_Quarter__c, currentQty4 + (fcRecord.Core_Opp_FC_Quantity__c - fcRecord.Core_FC_Approved_Claim_Quantity_nbr__c));
                                    
                                    QLwithQtrwithRemainingApprovedQty.put(fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c,QtrwithRemainingApprovedQty); 

                
				//system.debug('Log 1--'+QtrWithQty);
			}
            system.debug('Log 1--'+QLwithQtrwithRemainingApprovedQty);
            system.debug('Log 2--'+OLIWithQtrCnt);
            system.debug('Log 3--'+QLwithQtrQty);
            system.debug('Log 4--'+QLwithQtrApprovedQty);
            system.debug('Log 5--'+QLwithQtrRemainingQty);
            
			for (Core_Opp_FC_Prod_Schedule__c fcRecord : fcList) 
			{
                //system.debug('Log 1 FCRecord--'+fcRecord);
				
				if (QLWrp.containsKey(fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c)) 
				{    
					for (List<rebateClaimItemQuoteLineDetails> rcliDetailList : QLWrp.values()) {
						for (rebateClaimItemQuoteLineDetails rcliDetail : rcliDetailList){
                            
							if(fcRecord.Core_Opp_FC_Quarter__c == rcliDetail.RCLIQtr && fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c == rcliDetail.RCLIQL)
							{
                                String approvedQtyQtr;
                                
                                if (rcliDetail.RCLIStatus == 'Approved') 
								{
                                  //  system.debug('fcrecord--'+fcRecord);
                                    Decimal previousSchedQty = fcRecord.Core_Opp_FC_Quantity__c;
                                    Decimal oldApprovedQty = fcRecord.Core_FC_Approved_Claim_Quantity_nbr__c;
                                    system.debug('Previous schd qty --'+previousSchedQty);
                                    system.debug('Inside approved');
                                    
                                    system.debug('Qty from rebate claim--'+rcliDetail.RCLIQty);
                                    
                                    if(rcliDetail.RCLIQty > fcRecord.Core_Opp_FC_Quantity__c){
										fcRecord.Core_Opp_FC_Quantity__c = fcRecord.Core_FC_Approved_Claim_Quantity_nbr__c + rcliDetail.RCLIQty;
									}
                                    
                                    
									approvedQtyQtr = fcRecord.Core_Opp_FC_Quarter__c;
									fcRecord.Core_FC_Approved_Claim_Quantity_nbr__c += rcliDetail.RCLIQty;
									fcRecord.Core_FC_Submitted_Claim_Quantity_nbr__c -= rcliDetail.RCLIQty;
									/*if(fcRecord.Core_FC_Approved_Claim_Quantity_nbr__c > fcRecord.Core_Opp_FC_Quantity__c){
										fcRecord.Core_Opp_FC_Quantity__c = fcRecord.Core_FC_Approved_Claim_Quantity_nbr__c;
									} */
									//Decimal newApprovedQty = fcRecord.Core_FC_Approved_Claim_Quantity_nbr__c;								
									Decimal newApprovedQty = rcliDetail.RCLIQty;
                                    //Decimal oldApprovedQty = fcRecord.Core_FC_Approved_Claim_Quantity_nbr__c;
									Decimal additionalApprovedQty = 0;
									Decimal additionalScheduledQty = 0;
                                    
                                    system.debug('New approved qty is--'+newApprovedQty);
                                    system.debug('Old approved qty is--'+oldApprovedQty);
                                    
////////////////////////////////////block 1
									if (newApprovedQty == previousSchedQty) 
									{
                                        system.debug('Inside block 1');
                                    Map<String, Decimal> PreviousQtrMap1 = new Map<String, Decimal>();
                                    Map<String, Decimal> FutureQtrMap1 = new Map<String, Decimal>();
                                    Map<String, Decimal> FinalQtrQtyMap1 = new Map<String, Decimal>();
                                    
                                    Map<String, Date> QuarterEndDateMap1 = new Map<String, Date>();
                                        
									  // Determine the current quarter
									  String currentQuarter = getQuarterFromDate(Date.today());
									  //Get all previous and future qtrs based on quarter size from OLIWithQtrCnt
									  Integer qtrSize = OLIWithQtrCnt.get(fcRecord.Core_FC_Opportunity_Product__c);
									  List<String> previousQuarters = getPreviousQuarters(approvedQtyQtr, qtrSize);
									  List<String> futureQuarters = getFutureQuarters(approvedQtyQtr, qtrSize);
									  futureQuarters.add(approvedQtyQtr);
                                        
                                        Map<String, Decimal> QtrWithQtyMap = new Map<String, Decimal>();
                                    if (QLwithQtrQty.containsKey(fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c)) 
                                        {
											QtrWithQtyMap = QLwithQtrQty.get(fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c);
										}
                                        
									  for (String quarter : previousQuarters) 
									  {
										if (QtrWithQtyMap.containsKey(quarter)) 
										{
											if((quarter != approvedQtyQtr))
											{
											  Decimal qty = QtrWithQtyMap.get(quarter);
											  Date quarterEndDate = getQuarterEndDateFromQtrName(quarter);
											  // Store quarter end date for comparison
											  QuarterEndDateMap1.put(quarter, quarterEndDate);
											  // Add valid previousQtrs to PreviousQtrMap1
											  PreviousQtrMap1.put(quarter, qty);
											}
										}
									  }
									  Decimal additionalQtyInQtr = 0;
									  for (String quarter : PreviousQtrMap1.keySet()) {
										Decimal qty1 = PreviousQtrMap1.get(quarter);
										Date quarterEndDate1 = QuarterEndDateMap1.get(quarter);
										// Check if today's date is greater than the quarter's end date plus 30 days
										if (Date.today() > quarterEndDate1.addDays(30) && qty1 > 0) {
										  //make qty in previous qtr as 0 and store the exisitng qty in one var
										  additionalQtyInQtr += qty1;
										  // Reset the quantity for this quarter
										  PreviousQtrMap1.put(quarter, 0);
										}
                                          FinalQtrQtyMap1.put(quarter,PreviousQtrMap1.get(quarter));
									  }
                                        system.debug('Prev Qrt1 Map is--'+PreviousQtrMap1);
									
										//create futureMap and Add valid futureQtrs to FutureQtrMap1
									  for (String quarter : futureQuarters) {
										  Date qtrStartDate= getQuarterStartDateFromQtrName(approvedQtyQtr);
										  Date qtrEndDate = getQuarterEndDateFromQtrName(approvedQtyQtr);
										  if(Date.today() >= qtrStartDate && Date.today() <= qtrEndDate.addDays(30)){
											  if (QtrWithQtyMap.containsKey(quarter)) 
												{
												  Decimal qty = QtrWithQtyMap.get(quarter);
												  // Add to FutureQtrMap1
												  FutureQtrMap1.put(quarter, qty);
                                                    FinalQtrQtyMap1.put(quarter,FutureQtrMap1.get(quarter));
												}
										  }
										  else{
											if(!(quarter == fcRecord.Core_Opp_FC_Quarter__c)){
												if (QtrWithQtyMap.containsKey(quarter)) 
												{
												  Decimal qty = QtrWithQtyMap.get(quarter);
												  // Add to FutureQtrMap
												  FutureQtrMap1.put(quarter, qty);
                                                    FinalQtrQtyMap1.put(quarter,FutureQtrMap1.get(quarter));
												}
										  }
									  	}
									  }
                                        system.debug('future Qrt1 Map is--'+FutureQtrMap1);
                                        system.debug('Final Qrt1 Map is--'+FinalQtrQtyMap1);
									  Integer numberOfFutureQuarters = FutureQtrMap1.size();
									system.debug('Future Qtr numbers--'+numberOfFutureQuarters);
									  // If there are future quarters available to distribute the quantity
									  if (numberOfFutureQuarters > 0) 
                                      {
										// Calculate the quantity to add to each future quarter
										Decimal qtyPerFutureQuarter = additionalQtyInQtr / numberOfFutureQuarters;
										Integer qtyPerFutureQuarterRdOff = Math.round(qtyPerFutureQuarter);
										// Iterate over the future quarters and add the additional quantity
										for (String quarter : FutureQtrMap1.keySet()) 
                                        {
                                            system.debug('Qtr is--'+quarter);
                                            system.debug('Qty to be divided per qtr--'+qtyPerFutureQuarter);
                                            system.debug('Rounded qty--'+qtyPerFutureQuarterRdOff);
											if(qtyPerFutureQuarterRdOff <= additionalQtyInQtr)
                                            {
                                                Decimal existingQty = FutureQtrMap1.get(quarter);
                                                FutureQtrMap1.put(quarter, existingQty + qtyPerFutureQuarterRdOff);
                                                system.debug('updated Future Quarter: '+quarter+' with quantity: '+(existingQty + qtyPerFutureQuarterRdOff));
                                                additionalQtyInQtr -= qtyPerFutureQuarterRdOff;
                                                system.debug('Additional qty in qtr--'+additionalQtyInQtr);
											}
                                            else if(additionalQtyInQtr < qtyPerFutureQuarterRdOff)
                                            {
                                                    system.debug('Inside last divide');
													FutureQtrMap1.put(quarter, FutureQtrMap1.get(quarter) + additionalQtyInQtr);
                                            }
                                            FinalQtrQtyMap1.put(quarter,FutureQtrMap1.get(quarter));
										}
									  } 
                                      else {
											system.debug('No future qtrs available');
									  }
                                        QLwithQtrQtyMap.put(fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c, FinalQtrQtyMap1);
                                        //QLwithQtrQtyMap.put(fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c, FutureQtrMap1);
                                        
                                        system.debug('QLwithQtrQtyMap 1 is--'+QLwithQtrQtyMap);
//                                        updateFcListWithQuantities(fcList, PreviousQtrMap1, FutureQtrMap1);
									}
									
	////////////////////////////////block 2, Approved quantity is greater than scheduled quantity QtrWithQty
								if (newApprovedQty > previousSchedQty)
								{
                                    
                                    Map<String, Decimal> PreviousQtrMap2 = new Map<String, Decimal>();
                                    Map<String, Decimal> FutureQtrMap2 = new Map<String, Decimal>();
                                    Map<String, Decimal> FinalQtrQtyMap2 = new Map<String, Decimal>();
                                    Map<String, Date> QuarterEndDateMap2 = new Map<String, Date>();
                                    
                                    system.debug('Inside greater than block');
                                    system.debug('new app qty--'+newApprovedQty);
                                    system.debug('old app qty--'+oldApprovedQty);
                                    system.debug('old sch qty--'+previousSchedQty);
                                    
									additionalApprovedQty = (newApprovedQty + oldApprovedQty) - previousSchedQty;
                                    system.debug('additional qty--'+additionalApprovedQty);
                                    
                                    String currentQuarter = getQuarterFromDate(Date.today());
                                    Integer qtrSize = OLIWithQtrCnt.get(fcRecord.Core_FC_Opportunity_Product__c);
                                    List<String> previousQuarters = getPreviousQuarters(approvedQtyQtr, qtrSize);
                                    List<String> futureQuarters = getFutureQuarters(approvedQtyQtr, qtrSize);
                                    Map<String, Decimal> QtrWithQtyMap = new Map<String, Decimal>();
                                    if (QLwithQtrQty.containsKey(fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c)) 
                                        {
                                            system.debug('Inside if populate');
											QtrWithQtyMap = QLwithQtrQty.get(fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c);
										}
                                    
                                    //prepare previous qtr map
                                    for (String quarter : previousQuarters) 
                                    {
                                        if (QtrWithQtyMap.containsKey(quarter)) 
                                        {
                                            if((quarter != approvedQtyQtr)){
                                                system.debug('Previous Quarter Found: ' + quarter + ' with quantity: ' + QtrWithQtyMap.get(quarter));
                                                Decimal qty = QtrWithQtyMap.get(quarter);
                                                Date quarterEndDate = getQuarterEndDateFromQtrName(quarter);
                                                QuarterEndDateMap2.put(quarter, quarterEndDate);
                                                PreviousQtrMap2.put(quarter, qty);
                                                FinalQtrQtyMap2.put(quarter,PreviousQtrMap2.get(quarter));
                                            }
                                            
                                        }
                                    }
                                    system.debug('Previous Quarters Map: ' + PreviousQtrMap2);
                                    Decimal remainingQtyToFulfill = additionalApprovedQty;
            						Decimal remainingQtyToStore = 0;
                                    
                                    //see if we can adjust remaining qty from previous qtr
                                    for (String quarter : PreviousQtrMap2.keySet()) 
									{
										Decimal qty1 = PreviousQtrMap2.get(quarter);
										Date quarterEndDate1 = QuarterEndDateMap2.get(quarter);
										// Check if today's date is greater than the previous quarter's end date plus 30 days
										if (Date.today() > quarterEndDate1.addDays(30) && qty1 > 0) 
										{
                                            system.debug('Inside if 1');
                                            // Determine how much of the remaining quantity can be fulfilled by this quarter
                                            Decimal qtyToDeduct = Math.min(remainingQtyToFulfill, qty1);
                                            system.debug('Qty to deduct--'+qtyToDeduct+ ' for qtr  '+quarter);
                                            
                                            // Deduct the quantity from the current quarter
                                            PreviousQtrMap2.put(quarter, qty1 - qtyToDeduct);
                                            
                                            FinalQtrQtyMap2.put(quarter,PreviousQtrMap2.get(quarter));
                                            // Reduce the remaining quantity to fulfill
                                            remainingQtyToFulfill -= qtyToDeduct;
                                            system.debug('rmng qty--'+remainingQtyToFulfill);
                                            
                                            // Exit the loop if there's no remaining quantity to fulfill
                                            if (remainingQtyToFulfill <= 0) 
                                            {
                                                system.debug('Inside break of 2nd block');
                                                break;
											}
                                        }
                                    }
                                    system.debug('PRVqtr map is--'+PreviousQtrMap2);
                                    
                                        system.debug('Remaining qty to fulfill--'+remainingQtyToFulfill);
                                    	Decimal TotalQtyInFutureQtr = 0;
                                    
                                    	//prepare future quarter's map
                                        for (String quarter : futureQuarters) 
                                        {
                                                if (QtrWithQtyMap.containsKey(quarter)) 
                                                {
                                                    system.debug('Future Quarter Found: '+quarter+' with quantity: '+QtrWithQtyMap.get(quarter));
    
                                                    Decimal qty = QtrWithQtyMap.get(quarter);
                                                    FutureQtrMap2.put(quarter, qty);
                                                    TotalQtyInFutureQtr += FutureQtrMap2.get(quarter);
                                                }
                                        }
                                    system.debug('FTR Map-'+FutureQtrMap2);
                                    system.debug('TotalQtyInFutureQtrss--'+TotalQtyInFutureQtr);
                                    
                                	// Handle remaining quantities in previous quarters after fulfilling additionalApprovedQty
                                    for (String quarter : PreviousQtrMap2.keySet()) 
                                    {
                                        Decimal qty1 = PreviousQtrMap2.get(quarter);
										Date quarterEndDate1 = QuarterEndDateMap2.get(quarter);
                                        
                                        if (Date.today() > quarterEndDate1.addDays(30) && qty1 > 0) 
										{
                                        Decimal remainingQty = PreviousQtrMap2.get(quarter);
                                        system.debug('Remaining qty is--'+remainingQty);
                                            //store remaining qty from previous qtrs, to be distributed in future qtrs
                                            remainingQtyToStore += remainingQty;
                                            PreviousQtrMap2.put(quarter, 0); // Set quantity to 0 in the previous quarters
                                        	FinalQtrQtyMap2.put(quarter,PreviousQtrMap2.get(quarter));
                                            system.debug('Inside making 0 PrvQtr');
                                        }
                                    }
                                    system.debug('Remaining qty to be distributed in future is--'+remainingQtyToStore);
                                    
                                    // Use the stored quantities from previous qtrs for future quarters
                                    Decimal extraQty = 0;
                                    Decimal totalQtyDistributed = 0;
                                    Decimal initialTotalRemainingQtyToFulfill = remainingQtyToFulfill;
                                    Decimal totalConsumed = 0;
                                    
                                    system.debug('Remaining qty to be adjusted first time is--'+remainingQtyToFulfill);
                                    //qty can be fulfilled fully in future qtrs
                                    if(remainingQtyToFulfill > 0)
                                    {
                                        system.debug('Inside new if');
                                        for (String quarter : FutureQtrMap2.keySet()) 
                                        {
                                            if (FutureQtrMap2.get(quarter) > 0)
                                            {
                                                Decimal availableQty = FutureQtrMap2.get(quarter);
                                                if (availableQty <= remainingQtyToFulfill)
                                                {
                                                    system.debug('Consume fully');
                                                    //consume this qtr qty fully
                                                    remainingQtyToFulfill -= availableQty;
                                                    totalConsumed += availableQty;
                                                    FutureQtrMap2.put(quarter,0);
                                                }
                                                else
                                                {
                                                    system.debug('Consume partially');
                                                    //consume whatever is present and update qtr accordingly
                                                   FutureQtrMap2.put(quarter,availableQty - remainingQtyToFulfill);
                                                   totalConsumed += remainingQtyToFulfill;
                                                   remainingQtyToFulfill = 0;
                                                }
                                                FinalQtrQtyMap2.put(quarter,FutureQtrMap2.get(quarter));
                                            }
                                        }
                                        system.debug('Map is--'+FutureQtrMap2);
                                        system.debug('Total consumed is--'+totalConsumed);
                                        system.debug('Remaining qty to fulfill is--'+remainingQtyToFulfill);
                                        system.debug('Final future related map data is--'+FinalQtrQtyMap2);
                                    }
                                    
                                    Decimal qtyToBeConsumedFromPastQtr = remainingQtyToFulfill;
                                    system.debug('Remaining qty to be adjusted second time is--'+remainingQtyToFulfill);
                                    
                                    //already fulfilled from future but still remaining, fulfill from past
                                    if(qtyToBeConsumedFromPastQtr > 0)
                                    {
                                        Decimal totalConsumed2 = 0;
                                        system.debug('Inside adjusting remaining qty from past again');
                                         for (Map<String, Decimal> qtrWithRemainingApprovedQtyMap : QLwithQtrwithRemainingApprovedQty.values())
                                         {
                                            for (String quarter : qtrWithRemainingApprovedQtyMap.keySet())
                                            {
                                                if (PreviousQtrMap2.containsKey(quarter) && PreviousQtrMap2.get(quarter) > 0 && qtrWithRemainingApprovedQtyMap.get(quarter) > 0) 
                                                {
                                                    system.debug('Qtr with remaining approved qty mapppp---'+qtrWithRemainingApprovedQtyMap);
                                                    system.debug('Qtry with prev qtr--'+PreviousQtrMap2);
                                                    system.debug('Quarter to be updated--'+quarter);
                                                    Decimal availableQty = qtrWithRemainingApprovedQtyMap.get(quarter);//Remaining approved qty for particular qtr(scheduled-approved)
                                                    system.debug('available qty iss--'+availableQty);
                                                    system.debug('qty to be consumed from past qtr--'+qtyToBeConsumedFromPastQtr);
                                                    
                                                    if (availableQty > 0)
                                                    {
                                                        if (qtyToBeConsumedFromPastQtr > 0)
                                                        {
                                                            if (availableQty <= qtyToBeConsumedFromPastQtr) 
                                                            {
                                                                system.debug('Consume full prv qtrs');
                                                                //Consume fully
                                                                
                                                                totalConsumed2 += availableQty;
                                                                PreviousQtrMap2.put(quarter, PreviousQtrMap2.get(quarter) - qtyToBeConsumedFromPastQtr);
                                                                qtyToBeConsumedFromPastQtr -= availableQty;
                                                                system.debug('Update qtr--'+quarter+'--with qty--'+ PreviousQtrMap2.get(quarter));
                                                                system.debug('qtyToBeConsumedFromPastQtr after update--'+qtyToBeConsumedFromPastQtr);
                                                                //updated quarter
                                                                //quarterMap.put(quarter, 0); // Mark as consumed
                                                            } 
                                                            else 
                                                            {
                                                                system.debug('Consume partially prv qtrs');
                                                                // Consume partially
                                                              //  quarterMap.put(quarter, availableQty - qtyToBeConsumedFromPastQtr);
                                                                PreviousQtrMap2.put(quarter, PreviousQtrMap2.get(quarter) - qtyToBeConsumedFromPastQtr);
                                                                system.debug('Update qtr--'+quarter+'--with qty--'+ PreviousQtrMap2.get(quarter));
                                                                totalConsumed2 += qtyToBeConsumedFromPastQtr;
                                                                qtyToBeConsumedFromPastQtr = 0;
                                                            }
                                                        }
                                                    }
                                                    FinalQtrQtyMap2.put(quarter,PreviousQtrMap2.get(quarter));
                                                 }
                                            }
                                         }
                                    }
                                        system.debug('Previous qtr map--'+PreviousQtrMap2);
                                    system.debug('Final qtr map for previous qtrs updated--'+FinalQtrQtyMap2);
                                    
                                    /*
                                    if (remainingQtyToFulfill > 0) 
                                    {
                                        system.debug('Inside remainingQtyToFulfill ');
                                        Integer QrtWithoutZeroQty = 0;
                                        for (String quarter : FutureQtrMap2.keySet()) 
                                        {
                                            if(FutureQtrMap2.get(quarter) > 0){
                                            QrtWithoutZeroQty++;
                                        	}                                  
										}
                                        system.debug('QrtWithoutZeroQty--'+QrtWithoutZeroQty);
                                        if (QrtWithoutZeroQty > 0) 
                                        {
                                            Decimal qtyPerFutureQuarter = remainingQtyToFulfill / QrtWithoutZeroQty;
                                            Integer qtyPerFutureQuarterRdOff = Math.round(qtyPerFutureQuarter);
                                            Decimal qtyToDistribute = 0;
                                           
                                            for (String quarter : futureQuarters) 
                                            {
                                                if (QtrWithQtyMap.containsKey(quarter)) 
                                                {
                                                    if(FutureQtrMap2.get(quarter) > 0){
														system.debug('Qty to be divided per qtr--'+qtyPerFutureQuarter);
                                            			system.debug('Rounded qty--'+qtyPerFutureQuarterRdOff);
                                                        system.debug('Rem qty is--'+remainingQtyToFulfill);
                            							Decimal availableQty = FutureQtrMap2.get(quarter);
                                                        system.debug('Available qty is--'+availableQty);
                                                            // Determine the amount to distribute based on the minimum of the calculated quantity or available quantity
                                                        if(qtyPerFutureQuarterRdOff <= remainingQtyToFulfill)
                                                        {
                                                            qtyToDistribute = Math.min(qtyPerFutureQuarterRdOff, availableQty);
                                                            // Update FutureQtrMap2 with the distributed quantity
                                                            FutureQtrMap2.put(quarter, availableQty - qtyToDistribute);
                                                            system.debug('Actual qty adjusted is--'+qtyToDistribute + '--against total rounded off--'+qtyPerFutureQuarterRdOff+'--for remaining qty--'+remainingQtyToFulfill);
                                                            totalQtyDistributed += qtyToDistribute;
                                                            system.debug('Total qty distributed--'+totalQtyDistributed);
                                                            FinalQtrQtyMap2.put(quarter,FutureQtrMap2.get(quarter));
                                                            system.debug('Updated Future Quarter: ' + quarter + ' with quantity: ' + (availableQty - qtyToDistribute));
                                        
                                                            // Adjust remaining quantity to fulfill
                                                            remainingQtyToFulfill -= qtyToDistribute;
                                                            system.debug('Total qty to fulfill left--' + remainingQtyToFulfill);
                                                    	}
                                        
                                                            // If the distributed quantity was less than the rounded-off quantity, calculate the extra quantity
                                                            if (qtyToDistribute < qtyPerFutureQuarterRdOff) {
                                                                if(totalQtyDistributed <> initialTotalRemainingQtyToFulfill){
                                                                	extraQty = qtyPerFutureQuarterRdOff - qtyToDistribute;
                                                                }
                                                                    
                                                            }
                                                        system.debug('Extra qty left is --'+extraQty);
                                                            // Exit loop if there is no remaining quantity to fulfill
                                                            if (remainingQtyToFulfill <= 0) {
                                                                break;
                                                            }
                                                        }
                                                	}
                                                }
                                            system.debug('Previous qtr map--'+PreviousQtrMap2);
                                      		system.debug('FutureQtrMap--'+FutureQtrMap2);
                                            system.debug('FinalQtrQtyMap--'+FinalQtrQtyMap2); 
                                        } 
                                        else 
                                        {
                                            System.debug('No future quarters available to distribute remaining quantity.');
                                        }
                                    }
                                    system.debug('Extra qty left after for loop is --'+extraQty);
                                    */
                                    
                                    /*
                                    if(totalQtyDistributed < initialTotalRemainingQtyToFulfill)
                                    {
                                        
                                        Decimal remainingDecimal = initialTotalRemainingQtyToFulfill - totalQtyDistributed;
                                        system.debug('Decimal qty left--'+remainingDecimal);
                                        for (String quarter : FutureQtrMap2.keySet())
                                        {
                                            if (FutureQtrMap2.get(quarter) > 0)
                                            {
                                                Decimal qtrQty = FutureQtrMap2.get(quarter);
                                                Decimal qtyToAdd = Math.min(remainingDecimal, qtrQty);
                                                FutureQtrMap2.put(quarter, qtrQty - qtyToAdd);
                                                FinalQtrQtyMap2.put(quarter, FutureQtrMap2.get(quarter));
                                                system.debug('FTR map is--'+FutureQtrMap2);
                                                system.debug('Final map is--'+FinalQtrQtyMap2);
                                                system.debug('Added remaining qty--' + qtyToAdd + ' to the last quarter: ' + quarter);
                                                remainingDecimal -= qtyToAdd;
                                                system.debug('Rem decimal is--'+remainingDecimal);
                                                if (remainingDecimal <= 0)
                                                {
                                                    break;
                                                }
                                            }
                                        }
                                    } */

                                    if(remainingQtyToStore > 0){
                                        system.debug('Inside remainingQtyToStore');
                                        Integer futureQuarterCount = FutureQtrMap2.size();
											if (futureQuarterCount > 0) 
											{
												Decimal qtyPerFutureQuarter = remainingQtyToStore / futureQuarterCount;
												Integer qtyPerFutureQuarterRdOff = Math.round(qtyPerFutureQuarter);
												for (String quarter : futureQuarters) 
												{
													if (QtrWithQty.containsKey(quarter)) 
													{
														if(qtyPerFutureQuarterRdOff < remainingQtyToStore){
															Decimal currentQty = QtrWithQty.get(quarter);
															FutureQtrMap2.put(quarter, currentQty + qtyPerFutureQuarterRdOff);
															remainingQtyToStore -= qtyPerFutureQuarterRdOff;
															if(remainingQtyToStore < qtyPerFutureQuarterRdOff){
																FutureQtrMap2.put(quarter, FutureQtrMap2.get(quarter) + remainingQtyToStore);
                                                                FinalQtrQtyMap2.put(quarter,FutureQtrMap2.get(quarter));
															}
														}
													}
                                                    
												}
											} 
											else 
											{
												System.debug('No future quarters available to distribute remaining quantity.');
											}
           
                                    }
                                    
                                    Map<String, Decimal> QtrWithRejectedQtyMapLocal = new Map<String, Decimal>();
                                    Map<String, Decimal> RejectedqtyMapForPrevQtr = new Map<String, Decimal>();
                                    Decimal totalQtyDivided = 0;
                                    
                                    /*
                                    if (extraQty > 0) 
                                    {
                                        Map<String, Decimal> QtrWithQtyMapLocal = new Map<String, Decimal>();
                                        Decimal qtyToAdjust = extraQty;
                                        Decimal qtyToDistribute = 0;
                                        
                                        system.debug('qtyToAdjust--'+qtyToAdjust);
                                        system.debug('Extra quantity not distributed from future qtrs. Distribute in past qtrs based on remaining qty--Extra qty is : ' + extraQty);
                                        for(Id qlId : QLwithQtrRemainingQty.keySet())
                                        {
                                                    if(fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c == qlId)
                                                    {
                                                        QtrWithRejectedQtyMapLocal = QLwithQtrRemainingQty.get(fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c);
                                                        system.debug('Qtr rejectedqty map --'+QtrWithRejectedQtyMapLocal);
                                                    } 
                                        }
                                        
                                        for (String quarter : QtrWithRejectedQtyMapLocal.keySet()) 
                                        {
                                            if(PreviousQtrMap2.containsKey(quarter) && PreviousQtrMap2.get(quarter) > 0 && QtrWithRejectedQtyMapLocal.get(quarter) > 0){
                                                RejectedqtyMapForPrevQtr.put(quarter,QtrWithRejectedQtyMapLocal.get(quarter));
                                            }
                                        }
                                        system.debug('RejectedqtyMapForPrevQtr--'+RejectedqtyMapForPrevQtr);
                                        
                                        Integer rejectedQtyAvailableQtrs = RejectedqtyMapForPrevQtr.size();
                                            if(rejectedQtyAvailableQtrs > 0){
                                                system.debug('Inside rejected qtr adj');
                                                Decimal qtyPerQuarter = qtyToAdjust / rejectedQtyAvailableQtrs;
                                            	Integer qtyPerFutureQuarterRdOff = Math.round(qtyPerQuarter);
                                                
                                        for(String quarter : RejectedqtyMapForPrevQtr.keySet()){
                                                system.debug('Qty to be divided per qtr--'+qtyPerQuarter);
                                            	system.debug('Rounded qty--'+qtyPerFutureQuarterRdOff);
                                                system.debug('Rem qty is--'+qtyToAdjust);
                                                Decimal availableQty = PreviousQtrMap2.get(quarter);
                                                if(qtyPerFutureQuarterRdOff <= qtyToAdjust){
                                                            qtyToDistribute = Math.min(qtyPerFutureQuarterRdOff, availableQty);
                                                        }
                                                        else if(qtyPerFutureQuarterRdOff > qtyToAdjust){
                                                            qtyToDistribute = Math.min(qtyToAdjust, availableQty);
                                                        }
                                                system.debug('Available qty is--'+availableQty);
                                                system.debug('qtyToDistribute qty is--'+qtyToDistribute);
                                                PreviousQtrMap2.put(quarter, availableQty - qtyToDistribute);
                                                FinalQtrQtyMap2.put(quarter,PreviousQtrMap2.get(quarter));
                                                qtyToAdjust -= qtyToDistribute;
                                                system.debug('Qty to adjust left is--'+qtyToAdjust);                                                
                                            }
                                        }
                                        
                                    }
                                    */
                                    
                                    system.debug('Final qrt map --'+FinalQtrQtyMap2);
                                    system.debug('Qtr rejectedqty map final--'+QtrWithRejectedQtyMapLocal);
                                    system.debug('Qtr rejectedqty map final 2--'+RejectedqtyMapForPrevQtr);
                                    QLwithQtrQtyMap.put(fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c, FinalQtrQtyMap2);
                                    
                                    system.debug('QLwithQtrQtyMap2 is--'+QLwithQtrQtyMap);

                                }
                                
////////////////////////////////block 3
								else if (newApprovedQty < previousSchedQty) 
                                {
                                    system.debug('Inside block 3');
                                    
                                     Map<String, Decimal> PreviousQtrMap3 = new Map<String, Decimal>();
                                    Map<String, Decimal> FutureQtrMap3 = new Map<String, Decimal>();
                                    Map<String, Decimal> FinalQtrQtyMap3 = new Map<String, Decimal>();
                                    Map<String, Date> QuarterEndDateMap3 = new Map<String, Date>();
                                    
                                    // Get current quarter and determine previous quarters
                                    String currentQuarter = getQuarterFromDate(Date.today());
                                    Integer qtrSize = OLIWithQtrCnt.get(fcRecord.Core_FC_Opportunity_Product__c);
                                    List<String> previousQuarters = getPreviousQuarters(approvedQtyQtr, qtrSize);
                                    List<String> futureQuarters = getFutureQuarters(approvedQtyQtr, qtrSize);
                                    futureQuarters.add(approvedQtyQtr);
                                    system.debug('Future Quarters: ' + futureQuarters);
                                    
                                    Decimal totalPreviousQty = 0;
                                    Map<String, Decimal> QtrWithQtyMap = new Map<String, Decimal>();
                                     if (QLwithQtrQty.containsKey(fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c)) 
                                        {
											QtrWithQtyMap = QLwithQtrQty.get(fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c);
										}

                                    // Iterate through previous quarters and adjust quantities
                                    for (String quarter : previousQuarters) 
                                    {
                                        if (QtrWithQtyMap.containsKey(quarter)) 
                                        {
                                            if((quarter != approvedQtyQtr)){
                                                Decimal qty = QtrWithQtyMap.get(quarter);
                                                system.debug('Qtr' +quarter+ 'Qty -'+qty);
                                                Date quarterEndDate = getQuarterEndDateFromQtrName(quarter);
                                                QuarterEndDateMap3.put(quarter, quarterEndDate);
                                                
                                                // Check if today's date is more than 30 days after the quarter's end date
                                                if (Date.today() > quarterEndDate.addDays(30))
                                                {
                                                    system.debug('Inside if of 30+ days condition');
                                                    PreviousQtrMap3.put(quarter, qty);
                                                    totalPreviousQty += qty;
                                                }
                                            }
                                            FinalQtrQtyMap3.put(quarter,PreviousQtrMap3.get(quarter));
                                    	}
                                    }
                                    system.debug('Previous Qtr Map--'+PreviousQtrMap3);
                                    system.debug('Total Previous Qty--'+totalPreviousQty);
                                    
                                    for (String quarter : futureQuarters) {
                                      //exclude the qtr in which sch qty is updated based oninvoice date. 
                                      //That qtr should not be considered for qty distribution
                                      Date qtrStartDate= getQuarterStartDateFromQtrName(approvedQtyQtr);
                                        Date qtrEndDate = getQuarterEndDateFromQtrName(approvedQtyQtr);
                                        if(Date.today() >= qtrStartDate && Date.today() <= qtrEndDate.addDays(30)){
                                             if (QtrWithQtyMap.containsKey(quarter)) 
                                            {
                                              system.debug('Inside consider current qtr--');
                                              Decimal qty = QtrWithQtyMap.get(quarter);
                                        
                                              // Add to FutureQtrMap
                                              FutureQtrMap3.put(quarter, qty);
                                                FinalQtrQtyMap3.put(quarter,FutureQtrMap3.get(quarter));
                                            }
                                        }
										else{ 
                                              if(!(quarter == fcRecord.Core_Opp_FC_Quarter__c)){
                                                    if (QtrWithQtyMap.containsKey(quarter)) 
                                                    {
                                                        system.debug('Inside ignore current qtr');
                                                      system.debug('Future Quarter Found: ' + quarter + ' with quantity: ' + QtrWithQtyMap.get(quarter));
                                                      Decimal qty = QtrWithQtyMap.get(quarter);
                                                
                                                      // Add to FutureQtrMap
                                                      FutureQtrMap3.put(quarter, qty);
                                                        FinalQtrQtyMap3.put(quarter,FutureQtrMap3.get(quarter));
                                                    }
                                              }
                                        }
                                        
                                  }
                                    system.debug('Future Qtr Map-'+FutureQtrMap3);
                                    
                                    if (totalPreviousQty > 0) 
                                    {
                                        Integer futureQuarterCount = FutureQtrMap3.size();
                                        if (futureQuarterCount > 0) 
                                        {
                                            system.debug('cnt-'+futureQuarterCount);
                                            Decimal qtyPerFutureQuarter = totalPreviousQty / futureQuarterCount;
                                            system.debug('to adjust in future qtrs-'+qtyPerFutureQuarter);
                                            Integer qtyPerFutureQuarterRdOff = Math.Round(qtyPerFutureQuarter);
                                            system.debug('Future qtrs--'+futureQuarters);
                                            system.debug('Future qtrs map--'+FutureQtrMap3);
                                            
                                            for (String quarter : futureQuarters) 
                                            {
                                                
                                                if (QtrWithQtyMap.containsKey(quarter)) 
                                                {
                                                    system.debug('Quarter being considered for update--'+quarter);
                                                    system.debug('Quarter old qty--'+QtrWithQtyMap.get(quarter));
                                                    system.debug('Qty debugs--'+qtyPerFutureQuarterRdOff);
                                                    system.debug('Qty debugs2 --'+totalPreviousQty);
                                                    if(qtyPerFutureQuarterRdOff<= totalPreviousQty){
                                                        system.debug('Inside last if');
                                                        Decimal currentQty = QtrWithQtyMap.get(quarter);
                                                        FutureQtrMap3.put(quarter, currentQty + qtyPerFutureQuarterRdOff);
                                                        system.debug('Future qtr map individual--Quarter--'+quarter+'--new qty--'+currentQty + qtyPerFutureQuarterRdOff);
                                                    	totalPreviousQty -= qtyPerFutureQuarterRdOff;
                                                        if(totalPreviousQty < qtyPerFutureQuarterRdOff){
                                                            system.debug('Inside last if to adjust decimal qty');
                                                            FutureQtrMap3.put(quarter, FutureQtrMap3.get(quarter) + totalPreviousQty);
                                                        }
                                                    }
                                                    FinalQtrQtyMap3.put(quarter,FutureQtrMap3.get(quarter));
                                                }
                                            }
                                            for (String quarter : PreviousQtrMap3.keySet()) 
                                            {
                                                system.debug('Inside making 0');
                                                PreviousQtrMap3.put(quarter, 0);
                                                FinalQtrQtyMap3.put(quarter,PreviousQtrMap3.get(quarter));
                                            }
                                        } 
                                        else 
                                        {
                                            System.debug('No future quarters available to distribute remaining quantity.');
                                        }
                                    }  
                                    QLwithQtrQtyMap.put(fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c, FinalQtrQtyMap3);                                    
                                    system.debug('QLwithQtrQtyMap 3 is--'+QLwithQtrQtyMap);
                                }
                                    updateFcListWithQuantities(fcList, QLwithQtrQtyMap);
								break;
							}
								if(rcliDetail.RCLIStatus == 'Rejected') 
								{
										fcRecord.Core_FC_Submitted_Claim_Quantity_nbr__c = fcRecord.Core_FC_Submitted_Claim_Quantity_nbr__c-rcliDetail.RCLIQty;
										break;
								}
								if (rcliDetail.RCLIStatus == 'Submitted') 
								{
                                    //system.debug('Inside submitted');
                                    //system.debug('Log 3--'+fcRecord);
                                    //system.debug('Sub qty log 2--'+fcRecord.Core_FC_Submitted_Claim_Quantity_nbr__c);
									 fcRecord.Core_FC_Submitted_Claim_Quantity_nbr__c = fcRecord.Core_FC_Submitted_Claim_Quantity_nbr__c + rcliDetail.RCLIQty;
                                    //system.debug('Sub qty log 3--'+fcRecord.Core_FC_Submitted_Claim_Quantity_nbr__c);
									 break;
								}
							}
						}
					}
				}
			}
			update fcList;
            //system.debug('Fclist--'+fcList);
        }
        
        catch (Exception e) {
            logEntries.add(new Core_Log_Entry__c(Core_Message__c = 'Message',Core_Details__c = e.getMessage(), Core_Origin__c='PCC_RebateClaimApproveController.updateQtyOn6QPS', Core_Severity__c='Low', Core_When__c=System.Now(), Core_Project__c = 'Sales CRM'));    
            system.debug('ERROR '+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        finally{ 
            insert logEntries;
        } 
    }
    
    // Method to update fcList based on previous and future quarter maps
    public static void updateFcListWithQuantities(List<Core_Opp_FC_Prod_Schedule__c> fcList, Map<Id, Map<String, Decimal>> QLwithQtrQtyMap)
                                                  //Map<String, Decimal> PreviousQtrMap, Map<String, Decimal> FutureQtrMap, ) 
    {
        system.debug('Method called');
        Map<String, Decimal> QtrWithQtyMapforFC = new Map<String, Decimal>();
        for(Id qlId : QLwithQtrQtyMap.keySet())
        {
            system.debug('qlId value is--'+qlId);
            for(Core_Opp_FC_Prod_Schedule__c fcRecord : fcList)
            {
                system.debug('fcRec 1 --'+fcRecord);
                if(fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c == qlId)
                {
                    QtrWithQtyMapforFC = QLwithQtrQtyMap.get(fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c);
                    system.debug('QtrWithQtyMapforFC--'+QtrWithQtyMapforFC);
                    Decimal qtyToAdd = QtrWithQtyMapforFC.get(fcRecord.Core_Opp_FC_Quarter__c);
                    system.debug('qty to add is--'+qtyToAdd);
                	system.debug('fcrec--'+fcRecord);
                	system.debug('FcRecord log 1 before--'+fcRecord.Core_Opp_FC_Quantity__c);
                    if(qtyToAdd>=0){
                    fcRecord.Core_Opp_FC_Quantity__c = qtyToAdd;
                    }
                    system.debug('FcRecord log 1 after--'+fcRecord.Core_Opp_FC_Quantity__c);
                }
            }
        }
        system.debug('fcList=='+fcList);
    update fcList;
    }
	
     
    //get quarter end date based on quarter name
    public static Date getQuarterEndDateFromQtrName(String quarterName) {
        Integer year = Integer.valueOf(quarterName.substring(0, 4));
        String quarter = quarterName.substring(5);

        Date qtrEndDate;
        switch on quarter {
            when 'Q1' {
                qtrEndDate = Date.newInstance(year, 3, 31);
            }
            when 'Q2' {
                qtrEndDate = Date.newInstance(year, 6, 30);
            }
            when 'Q3' {
                qtrEndDate = Date.newInstance(year, 9, 30);
            }
            when 'Q4' {
                qtrEndDate = Date.newInstance(year, 12, 31);
            }
            when else {
                qtrEndDate = null;
            }
        }
        return qtrEndDate;
    }
    
    
    //get quarter start date based on quarter name
    public static Date getQuarterStartDateFromQtrName(String quarterName) {
        Integer year = Integer.valueOf(quarterName.substring(0, 4));
        String quarter = quarterName.substring(5);

        Date qtrStDate;
        switch on quarter {
            when 'Q1' {
                qtrStDate = Date.newInstance(year, 1, 1);
            }
            when 'Q2' {
                qtrStDate = Date.newInstance(year, 4, 1);
            }
            when 'Q3' {
                qtrStDate = Date.newInstance(year, 7, 1);
            }
            when 'Q4' {
                qtrStDate = Date.newInstance(year, 10, 1);
            }
            when else {
                qtrStDate = null;
            }
        }
        return qtrStDate;
    }
        
    // Method to get the current quarter based on today's date
    public static String getQuarterFromDate(Date today) {
        Integer month = today.month();
        Integer year = today.year();
        String quarter;
        
        if (month >= 1 && month <= 3) {
            quarter = year + '-Q1';
        } else if (month >= 4 && month <= 6) {
            quarter = year + '-Q2';
        } else if (month >= 7 && month <= 9) {
            quarter = year + '-Q3';
        } else {
            quarter = year + '-Q4';
        }
        return quarter;
    }
    
    // Method to get previous quarters based on the current quarter
    public static List<String> getPreviousQuarters(String currentQuarter, Integer qtrSize) {
        List<String> previousQuarters = new List<String>();
    
        // Split the current quarter into year and quarter
        String[] parts = currentQuarter.split('-Q');
        Integer currentYear = Integer.valueOf(parts[0]);
        Integer currentQtr = Integer.valueOf(parts[1]);
    
        // Loop to get previous quarters
        Integer count = 0;
        Integer year = currentYear;
        Integer quarter = currentQtr - 1;
    
        while (count < qtrSize) {
            if (quarter <= 0) {
                // Transition to previous year and set quarter to Q4
                year--;
                quarter = 4;
            }
            previousQuarters.add(year + '-Q' + quarter);
            count++;
            quarter--;
        }    
        return previousQuarters;
    }
    

 // Method to calculate future quarters based on the current quarter
    public static List<String> getFutureQuarters(String currentQuarter, Integer qtrSize) {
        List<String> futureQuarters = new List<String>();

        // Split the current quarter into year and quarter
        String[] parts = currentQuarter.split('-Q');
        Integer currentYear = Integer.valueOf(parts[0]);
        Integer currentQtr = Integer.valueOf(parts[1]);

        // Loop to calculate future quarters
        for (Integer i = 1; i <= qtrSize; i++) {
            Integer futureQtr = currentQtr + i;
            Integer futureYear = currentYear;

            // Handle year transition
            while (futureQtr > 4) {
                futureQtr -= 4; // Go back to Q1
                futureYear += 1; // Move to the next year
            }
            futureQuarters.add(futureYear + '-Q' + futureQtr);
        }
        return futureQuarters;
    }

    	
    public class rebateClaimItemQuoteLineDetails{
        public String RCLIStatus { get;set;}
        public Double RCLIQty { get;set;}
		public String RCLIQtr { get;set; }
        public String RCLIQL { get;set; }
	}
    
    //method backup 2 - 10-09-2024
    //
        /**************************************************************************************************************************************************
TWC3123-6334 - This method updates Submitted/Approved quantities on associated 6QPS records based on RCLI submission/approval/rejection
**************************************************************************************************************************************************/
    public static void updateQtyOn6QPS2(List<PCC_Rebate_Claim_Line_Item__c> rebateClaimLIList) {
        List<Core_Log_Entry__c> logEntries = new List<Core_Log_Entry__c>();
        try {
            Map<Id, Integer> OLIWithQtrCnt = new Map<Id, Integer>();
            Map<Id, Map<String, Decimal>> QLwithQtrQty = new Map<Id, Map<String, Decimal>>();
            Map<String, Decimal> QtrWithQty = new Map<String, Decimal>();
            Map<Id, Map<String, Decimal>> QLwithQtrQtyMap = new Map<Id, Map<String, Decimal>>();
            
            Map<Id, Map<String, Decimal>> QLwithQtrwithRemainingApprovedQty = new Map<Id, Map<String, Decimal>>();
            Map<String, Decimal> QtrwithRemainingApprovedQty = new Map<String, Decimal>();
            
            Map<Id, List<rebateClaimItemQuoteLineDetails>> QLWrp = new Map<Id, List<rebateClaimItemQuoteLineDetails>>();
            rebateClaimItemQuoteLineDetails qlWrapper = new rebateClaimItemQuoteLineDetails();
            
            for (PCC_Rebate_Claim_Line_Item__c rcl : rebateClaimLIList) {
                String Qrtr = Core_FC_ProductSchedule_Ctrl.getQuarter(rcl.PCC_Invoice_Date__c);
                qlWrapper = new rebateClaimItemQuoteLineDetails();
                qlWrapper.RCLIStatus = rcl.PCC_Status__c;
                qlWrapper.RCLIQty = rcl.PCC_Quantity__c;
                qlWrapper.RCLIQtr = Qrtr;
                qlWrapper.RCLIQL = rcl.PCC_Quote_Line_Number__c;                
                
                if (!QLWrp.containsKey(rcl.PCC_Quote_Line_Number__c)) {
                    QLWrp.put(rcl.PCC_Quote_Line_Number__c, new List<rebateClaimItemQuoteLineDetails>());
                }
                QLWrp.get(rcl.PCC_Quote_Line_Number__c).add(qlWrapper);
            }
            //System.debug('QLWrp :'+QLWrp);
            List<Core_Opp_FC_Prod_Schedule__c> fcList = [select id, name, Core_FC_Opportunity_Product__c,Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c,Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__r.Pricing_Approved_Start_Date_Dt__c, Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__r.Pricing_Approved_End_Date_Dt__c, Core_Opp_FC_Quarter__c, Core_Opp_FC_Quantity__c, Core_FC_Approved_Claim_Quantity_nbr__c, Core_FC_Submitted_Claim_Quantity_nbr__c, Core_FC_Remaining_Claim_Quantity_nbr__c from Core_Opp_FC_Prod_Schedule__c where Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c IN : QLWrp.keySet()];
            //system.debug('fcList '+fcList);
            for (Core_Opp_FC_Prod_Schedule__c fcRecord : fcList) {
                if (!OLIWithQtrCnt.containsKey(fcRecord.Core_FC_Opportunity_Product__c)) {
                    OLIWithQtrCnt.put(fcRecord.Core_FC_Opportunity_Product__c, 0);
                }
                
                Integer qtrSizeForFCRecord = OLIWithQtrCnt.get(fcRecord.Core_FC_Opportunity_Product__c);
                qtrSizeForFCRecord++;
                
                OLIWithQtrCnt.put(fcRecord.Core_FC_Opportunity_Product__c, qtrSizeForFCRecord);
                
                fcRecord.Core_FC_Submitted_Claim_Quantity_nbr__c = fcRecord.Core_FC_Submitted_Claim_Quantity_nbr__c == null? 0: fcRecord.Core_FC_Submitted_Claim_Quantity_nbr__c;
                fcRecord.Core_FC_Approved_Claim_Quantity_nbr__c = fcRecord.Core_FC_Approved_Claim_Quantity_nbr__c == null ? 0 : fcRecord.Core_FC_Approved_Claim_Quantity_nbr__c;
                
                if (!QLwithQtrQty.containsKey(fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c)) {
                    QLwithQtrQty.put(fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c,new Map<String, Decimal>());
                }
                
                QtrWithQty = QLwithQtrQty.get(fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c);
                
                if (!QtrWithQty.containsKey(fcRecord.Core_Opp_FC_Quarter__c)) {
                    QtrWithQty.put(fcRecord.Core_Opp_FC_Quarter__c, 0);
                }
                Decimal currentQty = QtrWithQty.get(fcRecord.Core_Opp_FC_Quarter__c);
                QtrWithQty.put(fcRecord.Core_Opp_FC_Quarter__c,currentQty + fcRecord.Core_Opp_FC_Quantity__c);
                QLwithQtrQty.put(fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c, QtrWithQty);
                
                if (!QLwithQtrwithRemainingApprovedQty.containsKey(fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c)) {
                    QLwithQtrwithRemainingApprovedQty.put(fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c, new Map<String, Decimal>());
                }
                
                QtrwithRemainingApprovedQty = QLwithQtrwithRemainingApprovedQty.get(fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c);
                
                if (!QtrwithRemainingApprovedQty.containsKey(fcRecord.Core_Opp_FC_Quarter__c)) {
                    QtrwithRemainingApprovedQty.put(fcRecord.Core_Opp_FC_Quarter__c, 0);
                }
                Decimal currentQty4 = QtrwithRemainingApprovedQty.get(fcRecord.Core_Opp_FC_Quarter__c);
                QtrwithRemainingApprovedQty.put(fcRecord.Core_Opp_FC_Quarter__c, currentQty4 + (fcRecord.Core_Opp_FC_Quantity__c - fcRecord.Core_FC_Approved_Claim_Quantity_nbr__c));
                
                QLwithQtrwithRemainingApprovedQty.put(fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c, QtrwithRemainingApprovedQty);
            } 
            
            system.debug('QLwithQtrwithRemainingApprovedQty--'+QLwithQtrwithRemainingApprovedQty);
            //system.debug('OLIWithQtrCnt--'+OLIWithQtrCnt);
            //system.debug('QLwithQtrQty--'+QLwithQtrQty);
            
            for (Core_Opp_FC_Prod_Schedule__c fcRecord : fcList) {
                //system.debug('Inside fcrecord for');
                //system.debug('FCRecord--'+fcRecord);
                if (QLWrp.containsKey(fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c)) {
                    //system.debug('Inside 1st if');
                    for (List<rebateClaimItemQuoteLineDetails> rcliDetailList : QLWrp.values()) {
                        //system.debug('List debug--'+rcliDetailList);
                        for (rebateClaimItemQuoteLineDetails rcliDetail : rcliDetailList) 
                        {
                            //system.debug('wrapper details--'+rcliDetail);
                            if (fcRecord.Core_Opp_FC_Quarter__c == rcliDetail.RCLIQtr && fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c == rcliDetail.RCLIQL) {
                                String approvedQtyQtr;
                                //system.debug('wrapper details2 --'+rcliDetail);
                                //system.debug('Log 2 FCRecord--'+fcRecord);
                                
                                Date QlStartDate = fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__r.Pricing_Approved_Start_Date_Dt__c;
                                Date QlEndDate = fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__r.Pricing_Approved_End_Date_Dt__c;
                                List<String> qtrsBetweenQLStartDtEndDt = getQuartersBetweenDates(QlStartDate, QlEndDate);
                                if (rcliDetail.RCLIStatus == 'Approved') {
                                    Decimal previousSchedQty = fcRecord.Core_Opp_FC_Quantity__c;
                                    Decimal oldApprovedQty = fcRecord.Core_FC_Approved_Claim_Quantity_nbr__c;
                                    Decimal qtyLeft = previousSchedQty - oldApprovedQty;
                                    
                                    //system.debug('Previous schd qty AND oldApprovedQty--'+previousSchedQty+' AND '+oldApprovedQty);
                                    //system.debug('Inside approved');
                                    //system.debug('Qty from rebate claim--'+rcliDetail.RCLIQty);
                                    
                                    fcRecord.Core_Opp_FC_Quantity__c = fcRecord.Core_FC_Approved_Claim_Quantity_nbr__c + rcliDetail.RCLIQty;
                                    
                                    approvedQtyQtr = fcRecord.Core_Opp_FC_Quarter__c;
                                    fcRecord.Core_FC_Approved_Claim_Quantity_nbr__c += rcliDetail.RCLIQty;
                                    fcRecord.Core_FC_Submitted_Claim_Quantity_nbr__c -= rcliDetail.RCLIQty;
                                    Decimal newApprovedQty = rcliDetail.RCLIQty;
                                    Decimal additionalApprovedQty = 0;
                                    Decimal additionalScheduledQty = 0;
                                    
                                    //system.debug('New approved qty is--'+newApprovedQty);
                                    //system.debug('Old approved qty is--'+oldApprovedQty);
                                    
////////////////////////////////////block 1
                                    if (newApprovedQty == previousSchedQty) {
                                        //system.debug('BLOCK 1, both are equal');
                                        Map<String, Decimal> PreviousQtrMap1 = new Map<String, Decimal>();
                                        Map<String, Decimal> FutureQtrMap1 = new Map<String, Decimal>();
                                        Map<String, Decimal> FinalQtrQtyMap1 = new Map<String, Decimal>();
                                        
                                        // Determine the current quarter
                                        String currentQuarter = getQuarterFromDate(Date.today());
                                        Integer qtrSize = OLIWithQtrCnt.get(fcRecord.Core_FC_Opportunity_Product__c);
                                        
                                        List<String> previousQuarters = getPreviousQuarters(currentQuarter, qtrSize);
                                        List<String> futureQuarters = getFutureQuarters(currentQuarter, qtrSize);
                                        futureQuarters.add(currentQuarter);
                                        
                                        //system.debug('Previous qtrlist--'+previousQuarters);
                                        //system.debug('Future qtrlist--'+futureQuarters);
                                        
                                        Map<String, Decimal> QtrWithQtyMap = new Map<String, Decimal>();
                                        if (QLwithQtrQty.containsKey(fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c)) {
                                            QtrWithQtyMap = QLwithQtrQty.get(fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c);
                                        }
                                        //system.debug('QtrWithQtyMap--'+QtrWithQtyMap);
                                        
                                        for (String quarter : previousQuarters) {
                                            if (qtrsBetweenQLStartDtEndDt.contains(quarter)) {
                                                if (quarter != approvedQtyQtr) {
                                                    Decimal qty = QtrWithQtyMap.get(quarter);
                                                    Date quarterEndDate = getQuarterEndDateFromQtrName(quarter);
                                                    PreviousQtrMap1.put(quarter, qty);
                                                }
                                            }
                                        }
                                        
                                        Decimal AdditionalToBeAdjustedInFutureFromPast = 0;
                                        
                                        for (Map<String, Decimal> qtrWithRemainingApprovedQtyMap : QLwithQtrwithRemainingApprovedQty.values()) {
                                            for (String quarter : qtrWithRemainingApprovedQtyMap.keySet()) {
                                                if (PreviousQtrMap1.containsKey(quarter) && PreviousQtrMap1.get(quarter) > 0 && qtrWithRemainingApprovedQtyMap.get(quarter) > 0) {
                                                    //system.debug('Qtr with remaining approved qty mapppp---'+qtrWithRemainingApprovedQtyMap);
                                                    //system.debug('Qtry with prev qtr--'+PreviousQtrMap1);
                                                    //system.debug('Quarter to be updated--'+quarter);
                                                    Decimal availableQty = qtrWithRemainingApprovedQtyMap.get(quarter); // Remaining approved qty for particular qtr(scheduled-approved)
                                                    //system.debug('available qty iss--'+availableQty);
                                                    if (availableQty > 0) {
                                                        //system.debug('Updated qtr--'+quarter+'--which has existing additional qty--'+ availableQty);
                                                        //system.debug('PreviousQtrMap1 before updating values--'+PreviousQtrMap1);
                                                        AdditionalToBeAdjustedInFutureFromPast += availableQty;
                                                        PreviousQtrMap1.put(quarter, 0);
                                                        //system.debug('PreviousQtrMap1 after updating values--'+PreviousQtrMap1);
                                                        QtrwithRemainingApprovedQty.put(quarter,0);
                                                        //system.debug('block 1 QtrwithRemainingApprovedQty qtr map update--'+QtrwithRemainingApprovedQty);
                                                    }
                                                    FinalQtrQtyMap1.put(quarter, PreviousQtrMap1.get(quarter));
                                                }
                                            }
                                        }
                                        
                                        //system.debug('Prev Qrt1 Map is after making 0--'+PreviousQtrMap1);
                                        
                                        // create futureMap and Add valid futureQtrs to FutureQtrMap1
                                        for (String quarter : futureQuarters) {
                                            if (qtrsBetweenQLStartDtEndDt.contains(quarter) && quarter != approvedQtyQtr) {
                                                Decimal qty = QtrWithQtyMap.get(quarter);
                                                // Add to FutureQtrMap
                                                FutureQtrMap1.put(quarter, qty);
                                                FinalQtrQtyMap1.put(quarter, FutureQtrMap1.get(quarter));
                                            }
                                        }
                                        
                                        //system.debug('future Qrt1 Map is--'+FutureQtrMap1);
                                        //system.debug('Final Qrt1 Map is--'+FinalQtrQtyMap1);
                                        
                                        Integer numberOfFutureQuarters = FutureQtrMap1.size();
                                        //system.debug('Future Qtr numbers--'+numberOfFutureQuarters);
                                        
                                        // If there are future quarters available to distribute the
                                        // quantity
                                        if (numberOfFutureQuarters > 0 && AdditionalToBeAdjustedInFutureFromPast >0) {
                                            // Calculate the quantity to add to each future quarter
                                            Decimal qtyPerFutureQuarter = AdditionalToBeAdjustedInFutureFromPast / numberOfFutureQuarters;
                                            Double qtyPerFutureQuarterRdOffDbl = Math.Floor(qtyPerFutureQuarter);
                                            Integer qtyPerFutureQuarterRdOff = (Integer)qtyPerFutureQuarterRdOffDbl;
                                            //system.debug('qtyPerFutureQuarterRdOff--floorValue'+qtyPerFutureQuarterRdOffDbl +'  '+qtyPerFutureQuarterRdOff);
                                            // Iterate over the future quarters and add the additional quantity
                                            for (String quarter : FutureQtrMap1.keySet()) {
                                                //system.debug('Qtr is--'+quarter);
                                                //system.debug('Qty to be divided per qtr--'+qtyPerFutureQuarter);
                                                //system.debug('Rounded qty--'+qtyPerFutureQuarterRdOff);
                                                if (qtyPerFutureQuarterRdOff <= AdditionalToBeAdjustedInFutureFromPast) {
                                                    Decimal existingQty = FutureQtrMap1.get(quarter);
                                                    FutureQtrMap1.put(quarter, existingQty + qtyPerFutureQuarterRdOff);
                                                    //system.debug('updated Future Quarter: '+quarter+' with quantity: '+(existingQty + qtyPerFutureQuarterRdOff));
                                                    QtrwithRemainingApprovedQty.put(quarter,QtrwithRemainingApprovedQty.get(quarter)+qtyPerFutureQuarterRdOff);
                                                    //system.debug('QtrwithRemainingApprovedQty block1'+QtrwithRemainingApprovedQty);
                                                    AdditionalToBeAdjustedInFutureFromPast -= qtyPerFutureQuarterRdOff;
                                                    //system.debug('Additional qty in qtr--'+AdditionalToBeAdjustedInFutureFromPast);
                                                } 
                                                else if (AdditionalToBeAdjustedInFutureFromPast < qtyPerFutureQuarterRdOff) {
                                                    //system.debug('Inside last divide');
                                                    FutureQtrMap1.put(quarter, FutureQtrMap1.get(quarter) + AdditionalToBeAdjustedInFutureFromPast);
                                                    QtrwithRemainingApprovedQty.put(quarter,QtrwithRemainingApprovedQty.get(quarter)+AdditionalToBeAdjustedInFutureFromPast);
                                                    //system.debug('QtrwithRemainingApprovedQty block 1'+QtrwithRemainingApprovedQty);
                                                }
                                                FinalQtrQtyMap1.put(quarter, FutureQtrMap1.get(quarter));
                                            }
                                        } 
                                        else {
                                            System.debug('No future quarters available to distribute remaining quantity.');
                                            String qtr = getQuarterFromDate(QlEndDate);
                                            FinalQtrQtyMap1.put(qtr, QtrWithQtyMap.get(qtr)+AdditionalToBeAdjustedInFutureFromPast);
                                            QtrwithRemainingApprovedQty.put(qtr,QtrwithRemainingApprovedQty.get(qtr)+AdditionalToBeAdjustedInFutureFromPast);
                                            //system.debug('block 1 else QtrwithRemainingApprovedQty qtr map update--'+QtrwithRemainingApprovedQty);
                                        }
                                        //system.debug('retention before QtrwithRemainingApprovedQty'+QtrwithRemainingApprovedQty);
                                        QtrwithRemainingApprovedQty.put(approvedQtyQtr,0);
                                        //system.debug('retention after QtrwithRemainingApprovedQty'+QtrwithRemainingApprovedQty);
                                        //system.debug('retention before QLwithQtrwithRemainingApprovedQty'+QLwithQtrwithRemainingApprovedQty);
                                        QLwithQtrwithRemainingApprovedQty.put(fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c,QtrwithRemainingApprovedQty);
                                        //system.debug('retention after QLwithQtrwithRemainingApprovedQty'+QLwithQtrwithRemainingApprovedQty);
                                        //system.debug('FinalQtrQtyMap1 at last--'+FinalQtrQtyMap1);
                                        
                                        //system.debug('qtr with qty map before update--'+QtrWithQtyMap);
                                        for(String qtr : QtrWithQtyMap.keySet()){
                                            if(PreviousQtrMap1.containsKey(qtr)){            
                                                QtrWithQtyMap.put(qtr,PreviousQtrMap1.get(qtr));
                                            }
                                            else if(FutureQtrMap1.containsKey(qtr)){            
                                                QtrWithQtyMap.put(qtr,FutureQtrMap1.get(qtr));
                                            }
                                            else if(qtr == approvedQtyQtr){
                                                QtrWithQtyMap.put(qtr, newApprovedQty);
                                            }
                                            
                                        } 
                                        //system.debug('qtr with qty map after update--'+QtrWithQtyMap);
                                        //system.debug('QLwithQtrQty before update--'+QLwithQtrQty);
                                        QLwithQtrQty.put(fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c,QtrWithQtyMap);
                                        //system.debug('QLwithQtrQty after update--'+QLwithQtrQty);
                                        
                                        
                                        QLwithQtrQtyMap.put(fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c, FinalQtrQtyMap1);
                                        system.debug('QLwithQtrQtyMap 1 is--'+QLwithQtrQtyMap);
                                    }
                                    
////////////////////////////////////block 2, Approved quantity is greater than scheduled quantity QtrWithQty
                                    if (newApprovedQty > previousSchedQty) {
                                        //system.debug('BLOCK 2, new approved Qty is greater than prev schedule Qty');
                                        Map<String, Decimal> PreviousQtrMap2 = new Map<String, Decimal>();
                                        Map<String, Decimal> FutureQtrMap2 = new Map<String, Decimal>();
                                        Map<String, Decimal> FinalQtrQtyMap2 = new Map<String, Decimal>();
                                        //system.debug('new app qty--'+newApprovedQty);
                                        //system.debug('old app qty--'+oldApprovedQty);
                                        //system.debug('prev sch qty--'+previousSchedQty);
                                        additionalApprovedQty = (newApprovedQty + oldApprovedQty) - previousSchedQty;
                                        //system.debug('additional qty--'+additionalApprovedQty);
                                        
                                        String currentQuarter = getQuarterFromDate(Date.today());
                                        Integer qtrSize = OLIWithQtrCnt.get(fcRecord.Core_FC_Opportunity_Product__c);
                                        
                                        List<String> previousQuarters = getPreviousQuarters(currentQuarter, qtrSize);
                                        List<String> futureQuarters = getFutureQuarters(currentQuarter, qtrSize);
                                        futureQuarters.add(currentQuarter);
                                        
                                        Map<String, Decimal> QtrWithQtyMap = new Map<String, Decimal>();
                                        if (QLwithQtrQty.containsKey(fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c)) {
                                            //system.debug('Inside if populate');
                                            QtrWithQtyMap = QLwithQtrQty.get(fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c);
                                        }
                                        
                                        // prepare previous qtr map
                                        for (String quarter : previousQuarters) {
                                            if (qtrsBetweenQLStartDtEndDt.contains(quarter)) {
                                                if (quarter != approvedQtyQtr) {
                                                    //system.debug('Previous Quarter Found: ' + quarter + ' with quantity: ' + QtrWithQtyMap.get(quarter));
                                                    Decimal qty = QtrWithQtyMap.get(quarter);
                                                    PreviousQtrMap2.put(quarter, qty);
                                                    FinalQtrQtyMap2.put(quarter, PreviousQtrMap2.get(quarter));
                                                }
                                            }
                                        }
                                        //system.debug('Previous Quarters Map: ' + PreviousQtrMap2);
                                        Decimal remainingQtyToFulfill = additionalApprovedQty;
                                        Decimal remainingQtyToStore = 0;
                                        Decimal remainingQtyForFuture = 0;
                                        
                                        if (remainingQtyToFulfill > 0) {
                                            Decimal totalConsumed2 = 0;
                                            //system.debug('Inside adjusting remaining qty from past');
                                            for (Map<String, Decimal> qtrWithRemainingApprovedQtyMap : QLwithQtrwithRemainingApprovedQty.values()) {
                                                for (String quarter : qtrWithRemainingApprovedQtyMap.keySet()) {
                                                    if (PreviousQtrMap2.containsKey(quarter) && PreviousQtrMap2.get(quarter) > 0 && qtrWithRemainingApprovedQtyMap.get(quarter) > 0) {
                                                        //system.debug('Qtr with remaining approved qty mapppp---'+qtrWithRemainingApprovedQtyMap);
                                                        //system.debug('Qtry with prev qtr--'+PreviousQtrMap2);
                                                        //system.debug('Quarter to be updated--'+quarter);
                                                        Decimal availableQty = qtrWithRemainingApprovedQtyMap.get(quarter); // Remaining approved qty for particular qtr(scheduled-approved)
                                                        //system.debug('available qty iss--'+availableQty);
                                                        //system.debug('qty to be consumed from past qtr--'+remainingQtyToFulfill);
                                                        if (availableQty > 0 && remainingQtyToFulfill >0) {
                                                            if (availableQty <= remainingQtyToFulfill) {
                                                                //system.debug('Consume full prv qtrs');
                                                                totalConsumed2 += availableQty;
                                                                PreviousQtrMap2.put(quarter, 0);
                                                                remainingQtyToFulfill -= availableQty;
                                                                //system.debug('Update qtr--'+quarter+'--with qty--'+ PreviousQtrMap2.get(quarter));
                                                                //system.debug('remainingQtyToFulfill after update--'+remainingQtyToFulfill);
                                                                QtrwithRemainingApprovedQty.put(quarter,0);
                                                                //system.debug('QtrwithRemainingApprovedQty block 2'+QtrwithRemainingApprovedQty);
                                                            } 
                                                            else {
                                                                //system.debug('Consume partially prv qtrs');
                                                                PreviousQtrMap2.put(quarter, PreviousQtrMap2.get(quarter) - remainingQtyToFulfill);
                                                                //system.debug('Update qtr--'+quarter+'--with qty--'+ PreviousQtrMap2.get(quarter));
                                                                QtrwithRemainingApprovedQty.put(quarter,QtrwithRemainingApprovedQty.get(quarter)- remainingQtyToFulfill);
                                                                //system.debug('QtrwithRemainingApprovedQty block 2'+QtrwithRemainingApprovedQty);
                                                                totalConsumed2 += remainingQtyToFulfill;
                                                                remainingQtyForFuture = PreviousQtrMap2.get(quarter);
                                                                remainingQtyToFulfill = 0;
                                                            }
                                                        }
                                                        FinalQtrQtyMap2.put(quarter, PreviousQtrMap2.get(quarter));
                                                    }
                                                }
                                            }
                                        }
                                        
                                        //system.debug('Final qtr after adusting in prev qtrs--'+FinalQtrQtyMap2);
                                        //system.debug('remainingQtyForFuture--'+remainingQtyForFuture);
                                        
                                        //system.debug('PRVqtr map is--'+PreviousQtrMap2);
                                        //system.debug('Remaining qty to fulfill--'+remainingQtyToFulfill);
                                        //remainingQtyToFulfill is additional approved qty which we could not completely fulfill in past qtrs
                                        //TotalQtyInFutureQtr is total available qty in all future qtrs, we will compare it against remainingQtyToFulfill and adjust how much ever we can
                                        
                                        Decimal TotalQtyInFutureQtr = 0;
                                        
                                        // prepare future quarter's map
                                        for (String quarter : futureQuarters) {
                                            if (qtrsBetweenQLStartDtEndDt.contains(quarter) && quarter != approvedQtyQtr) {
                                                //system.debug('Future Quarter Found: '+quarter+' with quantity: '+QtrWithQtyMap.get(quarter));
                                                Decimal qty = QtrWithQtyMap.get(quarter);
                                                FutureQtrMap2.put(quarter, qty);
                                                TotalQtyInFutureQtr += FutureQtrMap2.get(quarter);
                                            }
                                        }
                                        //system.debug('Future Map 2nd block-'+FutureQtrMap2);
                                        //system.debug('TotalQtyInFutureQtrss--'+TotalQtyInFutureQtr);
                                        
                                        Decimal QtyToBeSplitInFuture = 0;
                                        
                                        for (Map<String, Decimal> qtrWithRemainingApprovedQtyMap : QLwithQtrwithRemainingApprovedQty.values()) {
                                            for (String quarter : qtrWithRemainingApprovedQtyMap.keySet()) {
                                                if (PreviousQtrMap2.containsKey(quarter) && PreviousQtrMap2.get(quarter) > 0 && qtrWithRemainingApprovedQtyMap.get(quarter) > 0) {
                                                    //system.debug('Qtr with remaining approved qty map---'+qtrWithRemainingApprovedQtyMap);
                                                    //system.debug('Map with prev qtr--'+PreviousQtrMap2);
                                                    //system.debug('Quarter to be updated--'+quarter+'--where existing qty is--'+PreviousQtrMap2.get(quarter));
                                                    QtyToBeSplitInFuture += PreviousQtrMap2.get(quarter);
                                                    //system.debug('QtyToBeSplitInFuture--'+QtyToBeSplitInFuture);
                                                    PreviousQtrMap2.put(quarter, 0);
                                                    //system.debug('PreviousQtrMap2 after updating values--'+PreviousQtrMap2);
                                                    QtrwithRemainingApprovedQty.put(quarter,0);
                                                    //system.debug('QtrwithRemainingApprovedQty block 2'+QtrwithRemainingApprovedQty);
                                                    FinalQtrQtyMap2.put(quarter, PreviousQtrMap2.get(quarter));
                                                }
                                            }
                                        }
                                        
                                        //system.debug('Remaining qty to be distributed in future is--'+QtyToBeSplitInFuture);
                                        //remainingQtyToStore is the remaining qty which is left from past qtrs even after fulfilling approved qty
                                        
                                        // Use the stored quantities from previous qtrs for future
                                        // quarters
                                        Decimal extraQty = 0;
                                        Decimal totalQtyDistributed = 0;
                                        Decimal initialTotalRemainingQtyToFulfill = remainingQtyToFulfill;
                                        Decimal totalConsumed = 0;
                                        //system.debug('Remaining qty to be adjusted first time is--'+remainingQtyToFulfill);
                                        
                                        // remaining approved qty to be fulfilled in future qtrs, after adjusting from past qtrs
                                        if (remainingQtyToFulfill > 0) {
                                            //Decimal totalConsumed2 = 0;
                                            //system.debug('Inside adjusting remaining qty from future');
                                            //system.debug('Qtr with remaining approved qty mapppp---'+qtrWithRemainingApprovedQtyMap);
                                            for (Map<String, Decimal> qtrWithRemainingApprovedQtyMap : QLwithQtrwithRemainingApprovedQty.values()) {
                                                //system.debug('Qtr with remaining approved qty mapppp---'+qtrWithRemainingApprovedQtyMap);
                                                for (String quarter : qtrWithRemainingApprovedQtyMap.keySet()) {
                                                    //system.debug('Qtr with remaining approved qty mapppp---'+qtrWithRemainingApprovedQtyMap);
                                                    if (FutureQtrMap2.containsKey(quarter) && FutureQtrMap2.get(quarter) > 0 && qtrWithRemainingApprovedQtyMap.get(quarter) > 0) {
                                                        //system.debug('Qtr with remaining approved qty mapppp---'+qtrWithRemainingApprovedQtyMap);
                                                        //system.debug('Qtry with prev qtr--'+FutureQtrMap2);
                                                        //system.debug('Quarter to be updated--'+quarter);
                                                        Decimal availableQty = qtrWithRemainingApprovedQtyMap.get(quarter); // Remaining approved qty for particular qtr(scheduled-approved)
                                                        //system.debug('available qty iss--'+availableQty);
                                                        //system.debug('qty to be consumed from past qtr--'+remainingQtyToFulfill);
                                                        if (availableQty > 0 && remainingQtyToFulfill >0) {
                                                            if (availableQty <= remainingQtyToFulfill) {
                                                                //system.debug('Consume full prv qtrs');
                                                                //totalConsumed2 += availableQty;
                                                                FutureQtrMap2.put(quarter, 0);
                                                                QtrwithRemainingApprovedQty.put(quarter,0);
                                                                //system.debug('block 2 if QtrwithRemainingApprovedQty qtr map update--'+QtrwithRemainingApprovedQty);
                                                                remainingQtyToFulfill -= availableQty;
                                                                //system.debug('Update qtr--'+quarter+'--with qty--'+ FutureQtrMap2.get(quarter));
                                                                //system.debug('remainingQtyToFulfill after update--'+remainingQtyToFulfill);
                                                            } 
                                                            else {
                                                                //system.debug('Consume partially prv qtrs');
                                                                FutureQtrMap2.put(quarter, FutureQtrMap2.get(quarter) - remainingQtyToFulfill);
                                                                //system.debug('Update qtr--'+quarter+'--with qty--'+ FutureQtrMap2.get(quarter));
                                                                QtrwithRemainingApprovedQty.put(quarter,QtrwithRemainingApprovedQty.get(quarter)-remainingQtyToFulfill);
                                                                //system.debug('block 2 else QtrwithRemainingApprovedQty qtr map update--'+QtrwithRemainingApprovedQty);
                                                                //totalConsumed2 += remainingQtyToFulfill;
                                                                remainingQtyForFuture = FutureQtrMap2.get(quarter);
                                                                remainingQtyToFulfill = 0;
                                                            }
                                                        }
                                                        FinalQtrQtyMap2.put(quarter, FutureQtrMap2.get(quarter));
                                                    }
                                                }
                                            }
                                        }
                                        //system.debug('Remaining qty to be adjusted second time is--'+remainingQtyToFulfill);
                                        //system.debug('Previous qtr map--'+PreviousQtrMap2);
                                        //system.debug('Final qtr map for previous qtrs updated--'+FinalQtrQtyMap2);
                                        //system.debug('Remaining qty from past to be stored in future--'+QtyToBeSplitInFuture);
                                        //QtyToBeSplitInFuture is qty left from past qtrs to be split evenly in future qtrs`
                                        //system.debug('before QtyToBeSplitInFuture if QtrwithRemainingApprovedQty qtr map update--'+QtrwithRemainingApprovedQty);
                                        if (QtyToBeSplitInFuture > 0) {
                                            //system.debug('Inside QtyToBeSplitInFuture');
                                            Integer futureQuarterCount = FutureQtrMap2.size();
                                            if (futureQuarterCount > 0) {
                                                //system.debug('Future qtrs valid count'+futureQuarterCount);
                                                Decimal qtyPerFutureQuarter = QtyToBeSplitInFuture / futureQuarterCount;
                                                Double qtyPerFutureQuarterRdOffDbl = Math.Floor(qtyPerFutureQuarter);
                                                Integer qtyPerFutureQuarterRdOff = (Integer)qtyPerFutureQuarterRdOffDbl;
                                                
                                                //system.debug('qtyPerFutureQuarter--'+qtyPerFutureQuarter);
                                                //system.debug('qtyPerFutureQuarterRdOff--'+qtyPerFutureQuarterRdOff);
                                                for (String quarter : FutureQtrMap2.keySet()) {
                                                    if (qtrsBetweenQLStartDtEndDt.contains(quarter)) {
                                                        //system.debug('block 2 QtrwithRemainingApprovedQty qtr map update--'+QtrwithRemainingApprovedQty);
                                                        //system.debug('Qtr from ftrqtr map--'+quarter);
                                                        if (qtyPerFutureQuarterRdOff <= QtyToBeSplitInFuture) {
                                                            Decimal currentQty = QtrWithQty.get(quarter);
                                                            FutureQtrMap2.put(quarter, currentQty + qtyPerFutureQuarterRdOff);
                                                            FinalQtrQtyMap2.put(quarter, FutureQtrMap2.get(quarter));
                                                            QtrwithRemainingApprovedQty.put(quarter,QtrwithRemainingApprovedQty.get(quarter)+qtyPerFutureQuarterRdOff);
                                                            QtyToBeSplitInFuture -= qtyPerFutureQuarterRdOff;
                                                            //system.debug('block 2 QtrwithRemainingApprovedQty qtr map update--'+QtrwithRemainingApprovedQty);
                                                            if (QtyToBeSplitInFuture < qtyPerFutureQuarterRdOff) {
                                                                FutureQtrMap2.put(quarter, FutureQtrMap2.get(quarter) + QtyToBeSplitInFuture);
                                                                FinalQtrQtyMap2.put(quarter, FutureQtrMap2.get(quarter));
                                                                QtrwithRemainingApprovedQty.put(quarter,QtrwithRemainingApprovedQty.get(quarter)+QtyToBeSplitInFuture);
                                                                //system.debug('Final qtr map update--'+FinalQtrQtyMap2);
                                                                //system.debug('block 2 QtrwithRemainingApprovedQty qtr map update--'+QtrwithRemainingApprovedQty);
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                            
                                            else {
                                                //System.debug('No future quarters available to distribute remaining quantity.');
                                                String qtr = getQuarterFromDate(QlEndDate);
                                                decimal lastQtrQty = QtrWithQtyMap.get(qtr)+QtyToBeSplitInFuture+additionalApprovedQty;
                                                //system.debug('lastQtrQty--'+lastQtrQty);
                                                FinalQtrQtyMap2.put(qtr, lastQtrQty);
                                            }
                                        }
                                        //system.debug('Future qrt map 2 --'+FutureQtrMap2); 
                                        //system.debug('Final qrt map 2 --'+FinalQtrQtyMap2); 
                                        
                                        //system.debug('qtr with qty map before update--'+QtrWithQtyMap);
                                        for(String qtr : QtrWithQtyMap.keySet()){
                                            if(PreviousQtrMap2.containsKey(qtr)){            
                                                QtrWithQtyMap.put(qtr,PreviousQtrMap2.get(qtr));
                                            }
                                            else if(FutureQtrMap2.containsKey(qtr)){            
                                                QtrWithQtyMap.put(qtr,FutureQtrMap2.get(qtr));
                                            }
                                            else if(qtr == approvedQtyQtr){
                                                QtrWithQtyMap.put(qtr, newApprovedQty);
                                            }
                                            
                                        } 
                                        //system.debug('qtr with qty map after update--'+QtrWithQtyMap);
                                        //system.debug('QLwithQtrQty before update--'+QLwithQtrQty);
                                        QLwithQtrQty.put(fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c,QtrWithQtyMap);
                                        //system.debug('QLwithQtrQty after update--'+QLwithQtrQty);
                                        
                                        //system.debug('2 retention before QtrwithRemainingApprovedQty'+QtrwithRemainingApprovedQty);
                                        QtrwithRemainingApprovedQty.put(approvedQtyQtr,0);
                                        //system.debug('2 retention after QtrwithRemainingApprovedQty'+QtrwithRemainingApprovedQty);
                                        //system.debug('2 retention before QLwithQtrwithRemainingApprovedQty'+QLwithQtrwithRemainingApprovedQty);
                                        QLwithQtrwithRemainingApprovedQty.put(fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c,QtrwithRemainingApprovedQty);
                                        //system.debug('2 retention after QLwithQtrwithRemainingApprovedQty'+QLwithQtrwithRemainingApprovedQty);
                                        
                                        //system.debug('FutureQtrMap2--'+FutureQtrMap2);
                                        //system.debug('Final qrt map last --'+FinalQtrQtyMap2);   
                                        QLwithQtrQtyMap.put(fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c, FinalQtrQtyMap2);
                                        //system.debug('QLwithQtrQtyMap2 is--'+QLwithQtrQtyMap);
                                    }
                                    
////////////////////////////////////block 3
                                    else if (newApprovedQty < previousSchedQty) {
                                        //system.debug('BLOCK 3-- newApproved less than prev schedl');
                                        Map<String, Decimal> PreviousQtrMap3 = new Map<String, Decimal>();
                                        Map<String, Decimal> FutureQtrMap3 = new Map<String, Decimal>();
                                        Map<String, Decimal> FinalQtrQtyMap3 = new Map<String, Decimal>();
                                        Map<String, Date> QuarterEndDateMap3 =  new Map<String, Date>();
                                        
                                        Decimal totalToBeConsumed = 0;
                                        Decimal remainingScheduledQty = 0; //qtyLeft = previousSchedQty - oldApprovedQty
                                        if(oldApprovedQty == 0){
                                            //system.debug('Inside if 1');
                                            remainingScheduledQty = previousSchedQty - newApprovedQty; //to be distributed in future
                                        }
                                        if(previousSchedQty == oldApprovedQty){
                                            //system.debug('Inside if 2');
                                            totalToBeConsumed = newApprovedQty ; // to be taken from past/future
                                        }
                                        if(previousSchedQty > (oldApprovedQty+newApprovedQty)){
                                            //system.debug('Inside if 3');
                                            remainingScheduledQty = previousSchedQty - (oldApprovedQty+ newApprovedQty);
                                        }
                                        if(previousSchedQty < (oldApprovedQty+newApprovedQty)){
                                            //system.debug('Inside if 4');
                                            totalToBeConsumed =  (oldApprovedQty+ newApprovedQty) - previousSchedQty;
                                        }
                                        
                                        //system.debug('Rem sch qty--> '+remainingScheduledQty);
                                        //system.debug('totalToBeConsumed--> '+totalToBeConsumed);
                                        // Get current quarter and determine previous quarters
                                        String currentQuarter = getQuarterFromDate(Date.today());
                                        Integer qtrSize = OLIWithQtrCnt.get(fcRecord.Core_FC_Opportunity_Product__c);
                                        
                                        List<String> previousQuarters = getPreviousQuarters(currentQuarter, qtrSize);
                                        List<String> futureQuarters =  getFutureQuarters(currentQuarter, qtrSize);
                                        futureQuarters.add(currentQuarter);
                                        
                                        Decimal totalPreviousQty = 0;
                                        Map<String, Decimal> QtrWithQtyMap =  new Map<String, Decimal>();
                                        if (QLwithQtrQty.containsKey(fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c)) {
                                            QtrWithQtyMap = QLwithQtrQty.get(fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c);
                                        }
                                        
                                        // Iterate through previous quarters and adjust quantities
                                        for (String quarter : previousQuarters) {
                                            if (qtrsBetweenQLStartDtEndDt.contains(quarter) && quarter != approvedQtyQtr) {
                                                Decimal qty = QtrWithQtyMap.get(quarter);
                                                //system.debug('Qtr--' +quarter+ '--with Qty--'+qty);
                                                PreviousQtrMap3.put(quarter, qty);
                                                FinalQtrQtyMap3.put(quarter, PreviousQtrMap3.get(quarter));
                                            }
                                            
                                        }
                                        //system.debug('Previous Qtr Map--'+PreviousQtrMap3);
                                        //system.debug('Total Previous Qty--'+totalPreviousQty);
                                        
                                        for (Map<String, Decimal> qtrWithRemainingApprovedQtyMap : QLwithQtrwithRemainingApprovedQty.values()){
                                            for (String quarter : qtrWithRemainingApprovedQtyMap.keySet()) {
                                                if (PreviousQtrMap3.containsKey(quarter) && PreviousQtrMap3.get(quarter) > 0 && qtrWithRemainingApprovedQtyMap.get(quarter) > 0) {
                                                    
                                                    //system.debug('Qtr with remaining approved qty mapppp---'+qtrWithRemainingApprovedQtyMap);
                                                    //system.debug('Qtry with prev qtr--'+PreviousQtrMap3);
                                                    //system.debug('Quarter to be updated--'+quarter);
                                                    Decimal availableQty = qtrWithRemainingApprovedQtyMap.get(quarter); // Remaining approved qty for particular qtr(scheduled-approved)
                                                    //system.debug('available qty iss--'+availableQty);
                                                    if (availableQty > 0 && totalToBeConsumed > 0 ) {
                                                        if (availableQty <= totalToBeConsumed) {
                                                            //system.debug('Consume full prv qtrs');
                                                            PreviousQtrMap3.put(quarter, 0);
                                                            totalToBeConsumed -= availableQty;
                                                            //system.debug('Update qtr--'+quarter+'--with qty--'+ PreviousQtrMap3.get(quarter));
                                                            //system.debug('remainingQtyToFulfill after update--'+totalToBeConsumed);
                                                            QtrwithRemainingApprovedQty.put(quarter,0);
                                                            //system.debug('block 3 if QtrwithRemainingApprovedQty qtr map update--'+QtrwithRemainingApprovedQty);
                                                        } 
                                                        else {
                                                            //system.debug('Consume partially prv qtrs');
                                                            PreviousQtrMap3.put(quarter, PreviousQtrMap3.get(quarter) - totalToBeConsumed);
                                                            //system.debug('Update qtr--'+quarter+'--with qty--'+ PreviousQtrMap3.get(quarter));
                                                            QtrwithRemainingApprovedQty.put(quarter,QtrwithRemainingApprovedQty.get(quarter)- totalToBeConsumed);
                                                            //system.debug('block 3 if QtrwithRemainingApprovedQty qtr map update--'+QtrwithRemainingApprovedQty);
                                                            //totalConsumed2 += remainingQtyToFulfill;
                                                            //remainingQtyForFuture = PreviousQtrMap2.get(quarter);
                                                            totalToBeConsumed = 0;
                                                        }
                                                        
                                                    }
                                                    FinalQtrQtyMap3.put(quarter, PreviousQtrMap3.get(quarter));
                                                }
                                            }
                                        }
                                        
                                        
                                        
                                        Decimal AdditionalToBeAdjustedInFutureFromPast = 0;
                                        for (Map<String, Decimal> qtrWithRemainingApprovedQtyMap : QLwithQtrwithRemainingApprovedQty.values()){
                                            for (String quarter : qtrWithRemainingApprovedQtyMap.keySet()) {
                                                if (PreviousQtrMap3.containsKey(quarter) && PreviousQtrMap3.get(quarter) > 0 && qtrWithRemainingApprovedQtyMap.get(quarter) > 0) {
                                                    //system.debug('Qtr with remaining approved qty mapppp---'+qtrWithRemainingApprovedQtyMap);
                                                    //system.debug('Qtry with prev qtr--'+PreviousQtrMap3);
                                                    //system.debug('Quarter to be updated--'+quarter);
                                                    Decimal availableQty = qtrWithRemainingApprovedQtyMap.get(quarter); // Remaining approved qty for particular qtr(scheduled-approved)
                                                    //system.debug('available qty iss--'+availableQty);
                                                    //system.debug('qty to be consumed from past qtr--'+qtyToBeConsumedFromPastQtr);
                                                    if (availableQty > 0) {
                                                        //system.debug('Updated qtr--'+quarter+'--which has existing additional qty--'+ availableQty);
                                                        //system.debug('PreviousQtrMap2 before updating values--'+PreviousQtrMap3);
                                                        AdditionalToBeAdjustedInFutureFromPast += availableQty;
                                                        PreviousQtrMap3.put(quarter, 0);
                                                        //system.debug('PreviousQtrMap2 after updating values--'+PreviousQtrMap3);
                                                        QtrwithRemainingApprovedQty.put(quarter, 0);
                                                        //system.debug('block 3 if QtrwithRemainingApprovedQty qtr map update--'+QtrwithRemainingApprovedQty);
                                                    }
                                                    FinalQtrQtyMap3.put(quarter, PreviousQtrMap3.get(quarter));
                                                }
                                            }
                                        }
                                        
                                        
                                        
                                        for (String quarter : futureQuarters) {
                                            if (qtrsBetweenQLStartDtEndDt.contains(quarter) && quarter != approvedQtyQtr) {
                                                //system.debug('Future Quarter Found:-- ' + quarter + '--with quantity: ' + QtrWithQtyMap.get(quarter));
                                                Decimal qty = QtrWithQtyMap.get(quarter);
                                                // Add to FutureQtrMap
                                                FutureQtrMap3.put(quarter, qty);
                                                FinalQtrQtyMap3.put(quarter, FutureQtrMap3.get(quarter));
                                            }
                                        }
                                        //system.debug('Future Qtr Map-'+FutureQtrMap3);
                                        
                                        if(totalToBeConsumed > 0){
                                            //system.debug('Inside new if');
                                            //system.debug('Inside adjusting remaining qty from future');
                                            for (Map<String, Decimal> qtrWithRemainingApprovedQtyMap : QLwithQtrwithRemainingApprovedQty.values()) {
                                                for (String quarter : qtrWithRemainingApprovedQtyMap.keySet()) {
                                                    if (FutureQtrMap3.containsKey(quarter) && FutureQtrMap3.get(quarter) > 0 && qtrWithRemainingApprovedQtyMap.get(quarter) > 0) {
                                                        //system.debug('Qtr with remaining approved qty mapppp---'+qtrWithRemainingApprovedQtyMap);
                                                        //system.debug('Qtry with prev qtr--'+FutureQtrMap3);
                                                        //system.debug('Quarter to be updated--'+quarter);
                                                        Decimal availableQty = qtrWithRemainingApprovedQtyMap.get(quarter); // Remaining approved qty for particular qtr(scheduled-approved)
                                                        //system.debug('available qty iss--'+availableQty);
                                                        //system.debug('qty to be consumed from future qtr--'+totalToBeConsumed);
                                                        if (availableQty > 0 && totalToBeConsumed >0) {
                                                            if (availableQty <= totalToBeConsumed) {
                                                                //system.debug('Consume full prv qtrs');
                                                                if(FutureQtrMap3.get(quarter) == availableQty){
                                                                    FutureQtrMap3.put(quarter, 0);
                                                                    //system.debug('inside if making FutureQtrMap3 as 0--'+QtrwithRemainingApprovedQty);
                                                                }
                                                                else {
                                                                    FutureQtrMap3.put(quarter,FutureQtrMap3.get(quarter) - totalToBeConsumed);
                                                                    //system.debug('inside else making FutureQtrMap3 as approved - available qty --'+QtrwithRemainingApprovedQty);
                                                                }
                                                                totalToBeConsumed -= availableQty;
                                                                //system.debug('Update qtr--'+quarter+'--with qty--'+ FutureQtrMap3.get(quarter));
                                                                //system.debug('totalToBeConsumed after update--'+totalToBeConsumed);
                                                                QtrwithRemainingApprovedQty.put(quarter,0);
                                                                //system.debug('block 3 if QtrwithRemainingApprovedQty qtr map update--'+QtrwithRemainingApprovedQty);
                                                            } 
                                                            else {
                                                                //system.debug('Consume partially prv qtrs');
                                                                FutureQtrMap3.put(quarter, FutureQtrMap3.get(quarter) - totalToBeConsumed);
                                                                //system.debug('Update qtr--'+quarter+'--with qty--'+ FutureQtrMap3.get(quarter));
                                                                QtrwithRemainingApprovedQty.put(quarter,QtrwithRemainingApprovedQty.get(quarter)-totalToBeConsumed);
                                                                //system.debug('block 3 else QtrwithRemainingApprovedQty qtr map update--'+QtrwithRemainingApprovedQty);
                                                                totalToBeConsumed = 0;
                                                            }
                                                        }
                                                        FinalQtrQtyMap3.put(quarter, FutureQtrMap3.get(quarter));
                                                    }
                                                }
                                            }
                                            //totalConsumed is total quantity that we consumed from future qtrs for additional approved qty
                                            //system.debug('Map is--'+FutureQtrMap3);
                                            //system.debug('Remaining qty to fulfill is--'+totalToBeConsumed);
                                            //system.debug('Final future related map data is--'+FinalQtrQtyMap3);
                                            
                                        }
                                        
                                        Decimal totalQtyToBeAdjustedInFuture = remainingScheduledQty + AdditionalToBeAdjustedInFutureFromPast;
                                        //system.debug('totalQtyToBeAdjustedInFuture---'+totalQtyToBeAdjustedInFuture);
                                        if (totalQtyToBeAdjustedInFuture > 0)
                                        {
                                            Integer futureQuarterCount = FutureQtrMap3.size();
                                            //system.debug('Future qtr cnt-'+futureQuarterCount);
                                            if (futureQuarterCount > 0)
                                            {
                                                Decimal qtyPerFutureQuarter = totalQtyToBeAdjustedInFuture / futureQuarterCount;
                                                //system.debug('to adjust in future qtrs-'+qtyPerFutureQuarter);
                                                Double qtyPerFutureQuarterRdOffDbl = Math.Floor(qtyPerFutureQuarter);
                                                Integer qtyPerFutureQuarterRdOff = (Integer)qtyPerFutureQuarterRdOffDbl;
                                                //system.debug('qtyPerFutureQuarterRdOff--floorValue'+qtyPerFutureQuarterRdOffDbl +'  '+qtyPerFutureQuarterRdOff);
                                                //system.debug('Future qtrs map--'+FutureQtrMap3);
                                                
                                                for (String quarter : FutureQtrMap3.keyset()) {
                                                    if (qtrsBetweenQLStartDtEndDt.contains(quarter)) {
                                                        //system.debug('block 3 QtrwithRemainingApprovedQty qtr map update--'+QtrwithRemainingApprovedQty);
                                                        //system.debug('Quarter being considered for update--'+quarter);
                                                        //system.debug('Quarter old qty--'+QtrWithQtyMap.get(quarter));
                                                        //system.debug('Qty to be adjusted in this qtr--'+qtyPerFutureQuarterRdOff);
                                                        if (qtyPerFutureQuarterRdOff <= totalQtyToBeAdjustedInFuture) {
                                                            //system.debug('Inside adjust 1st if');
                                                            Decimal currentQty = QtrWithQtyMap.get(quarter);
                                                            FutureQtrMap3.put(quarter, currentQty + qtyPerFutureQuarterRdOff);
                                                            //system.debug('Qty updates in qtr--'+quarter+'--is--'+FutureQtrMap3.get(quarter));
                                                            QtrwithRemainingApprovedQty.put(quarter,QtrwithRemainingApprovedQty.get(quarter)+qtyPerFutureQuarterRdOff);
                                                            //system.debug('QtrwithRemainingApprovedQty block3'+QtrwithRemainingApprovedQty);
                                                            totalQtyToBeAdjustedInFuture -= qtyPerFutureQuarterRdOff;
                                                            //system.debug('Remaining totalQtyToBeAdjustedInFuture after update--'+totalQtyToBeAdjustedInFuture);
                                                            if (totalQtyToBeAdjustedInFuture < qtyPerFutureQuarterRdOff) {
                                                                //system.debug('Inside last if to adjust decimal qty--'+totalQtyToBeAdjustedInFuture);
                                                                FutureQtrMap3.put(quarter, FutureQtrMap3.get(quarter)+ totalQtyToBeAdjustedInFuture);
                                                                QtrwithRemainingApprovedQty.put(quarter,QtrwithRemainingApprovedQty.get(quarter)+totalQtyToBeAdjustedInFuture);
                                                                //system.debug('QtrwithRemainingApprovedQty block3 last value'+QtrwithRemainingApprovedQty);
                                                            }
                                                        }
                                                        FinalQtrQtyMap3.put(quarter, FutureQtrMap3.get(quarter));
                                                    }
                                                }
                                                //system.debug('Final map after all updates to future--'+FinalQtrQtyMap3);
                                            }
                                            
                                            else {
                                                //System.debug('No future quarters available to distribute remaining quantity.');
                                                String qtr = getQuarterFromDate(QlEndDate);
                                                decimal lastQtrQty = QtrWithQtyMap.get(qtr)+ AdditionalToBeAdjustedInFutureFromPast ;
                                                //system.debug('lastQtrQty--'+lastQtrQty);
                                                FinalQtrQtyMap3.put(qtr, lastQtrQty);
                                            }
                                        }
                                        
                                        //system.debug('qtr with qty map before update--'+QtrWithQtyMap);
                                        for(String qtr : QtrWithQtyMap.keySet()){
                                            if(PreviousQtrMap3.containsKey(qtr)){            
                                                QtrWithQtyMap.put(qtr,PreviousQtrMap3.get(qtr));
                                            }
                                            else if(FutureQtrMap3.containsKey(qtr)){            
                                                QtrWithQtyMap.put(qtr,FutureQtrMap3.get(qtr));
                                            }
                                            else if(qtr == approvedQtyQtr){
                                                QtrWithQtyMap.put(qtr, newApprovedQty);
                                            }
                                            
                                        } 
                                        //system.debug('qtr with qty map after update--'+QtrWithQtyMap);
                                        //system.debug('QLwithQtrQty before update--'+QLwithQtrQty);
                                        QLwithQtrQty.put(fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c,QtrWithQtyMap);
                                        //system.debug('QLwithQtrQty after update--'+QLwithQtrQty);
                                        
                                        system.debug('3 retention before QtrwithRemainingApprovedQty'+QtrwithRemainingApprovedQty);
                                        //QtrwithRemainingApprovedQty.put(approvedQtyQtr,QtrwithRemainingApprovedQty.get(approvedQtyQtr)-newApprovedQty);
                                        QtrwithRemainingApprovedQty.put(approvedQtyQtr,0);
                                        //system.debug('3 retention after QtrwithRemainingApprovedQty'+QtrwithRemainingApprovedQty);
                                        //system.debug('3 retention before QLwithQtrwithRemainingApprovedQty'+QLwithQtrwithRemainingApprovedQty);
                                        QLwithQtrwithRemainingApprovedQty.put(fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c,QtrwithRemainingApprovedQty);
                                        //system.debug('3 retention after QLwithQtrwithRemainingApprovedQty'+QLwithQtrwithRemainingApprovedQty);
                                        
                                        //system.debug('Final qtr map after all updates to past--'+FinalQtrQtyMap3);
                                        QLwithQtrQtyMap.put(fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c, FinalQtrQtyMap3);
                                        //system.debug('QLwithQtrQtyMap 3 is--'+QLwithQtrQtyMap);
                                    }
                                    updateFcListWithQuantities2(fcList, QLwithQtrQtyMap); 
                                    //break; 
                                }
                                if (rcliDetail.RCLIStatus == 'Rejected') {
                                    fcRecord.Core_FC_Submitted_Claim_Quantity_nbr__c = fcRecord.Core_FC_Submitted_Claim_Quantity_nbr__c - rcliDetail.RCLIQty;
                                    //break;
                                }
                                if (rcliDetail.RCLIStatus == 'Submitted') {
                                    fcRecord.Core_FC_Submitted_Claim_Quantity_nbr__c = fcRecord.Core_FC_Submitted_Claim_Quantity_nbr__c + rcliDetail.RCLIQty;
                                    //break;
                                }
                            }
                        }
                    }
                }
            }
            update fcList;
        }
        
        catch (Exception e) {
            logEntries.add(new Core_Log_Entry__c(Core_Message__c = 'Message',Core_Details__c = e.getMessage(), Core_Origin__c='PCC_RebateClaimApproveController.updateQtyOn6QPS', Core_Severity__c='Low', Core_When__c=System.Now(), Core_Project__c = 'Sales CRM'));    
            //system.debug('ERROR '+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        finally{ 
            insert logEntries;
        } 
    }
    
    
    //Method to update fcList based on previous and future quarter maps
    public static void updateFcListWithQuantities2(List<Core_Opp_FC_Prod_Schedule__c> fcList, Map<Id, Map<String, Decimal>> QLwithQtrQtyMap)
        //Map<String, Decimal> PreviousQtrMap, Map<String, Decimal> FutureQtrMap, ) 
    {
        //system.debug('Method called');
        Map<String, Decimal> QtrWithQtyMapforFC = new Map<String, Decimal>();
        for(Id qlId : QLwithQtrQtyMap.keySet())
        {
            //system.debug('qlId value is--'+qlId);
            for(Core_Opp_FC_Prod_Schedule__c fcRecord : fcList)
            {
                //system.debug('fcRec 1 --'+fcRecord);
                if(fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c == qlId)
                {
                    QtrWithQtyMapforFC = QLwithQtrQtyMap.get(fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c);
                    //system.debug('QtrWithQtyMapforFC--'+QtrWithQtyMapforFC);
                    Decimal qtyToAdd = QtrWithQtyMapforFC.get(fcRecord.Core_Opp_FC_Quarter__c);
                    //system.debug('qty to add is--'+qtyToAdd);
                    //system.debug('fcrec--'+fcRecord);
                    //system.debug('FcRecord log 1 before--'+fcRecord.Core_Opp_FC_Quantity__c);*/
                    if(qtyToAdd>=0){
                        fcRecord.Core_Opp_FC_Quantity__c = qtyToAdd;
                    }
                    //system.debug('FcRecord log 1 after--'+fcRecord.Core_Opp_FC_Quantity__c);
                }
            }
        }
        //system.debug('fcList=='+fcList);
        update fcList;
    }
    
    //To get quarters between specific dates
    public static List<String> getQuartersBetweenDates(Date startDate, Date endDate)
    {
        List<String> quarters = new List<String>();
        
        Integer startYear = startDate.year();
        Integer endYear = endDate.year();
        Integer startQuarter = (startDate.month() - 1) / 3 + 1;
        Integer endQuarter = (endDate.month() - 1) / 3 + 1;
        for (Integer year = startYear; year <= endYear; year++) {
            Integer startQtr = (year == startYear) ? startQuarter : 1;
            Integer endQtr = (year == endYear) ? endQuarter : 4;
            for (Integer qtr = startQtr; qtr <= endQtr; qtr++) {
                String quarterString = year + '-Q' + qtr;
                quarters.add(quarterString);
            }
        }
        return quarters;
    }   
    
}