//-------------------------------------------//
//  Project: Satyam
//  Created By: Exceller tech
//  Created Date: 06-11-2023
//-------------------------------------------//
public class Ex_DemandManagementServices {
    public static void raiseDemand(Payment_Milestone__c pm) {
        if (pm != null) {
            // Update Payment Milestone
            pm.Is_Raised__c = true;
            //pm.Is_Due__c = true;
            pm.Demand_Raised_Date__c = system.today();
            Decimal onAccountBalance = 0;
            
            onAccountBalance = getOnAccountBalance(pm.Quotation__r.Booking__c);
            system.debug('onAccountBalance: '+onAccountBalance);
            
            // Raise Demand
            Demand__c d = new Demand__c();
            d.Demand_Type__c = 'Flat Cost';
            d.Booking__c = pm.Quotation__r.Booking__c;
            d.Quotation__c = pm.Quotation__c;
            d.Payment_Milestone__c = pm.Id;
            d.Milestone_Name__c = pm.Milestone_Name__c;
            d.Invoice_Date__c = pm.Due_Date__c;
    
            if(pm.Quotation__r.Booking__r.Project__r.CRM_Head__c != null){
             	d.CRM_Approval__c = pm.Quotation__r.Booking__r.Project__r.CRM_Head__c;   
            }
            if(pm.Due_Date__c!=null)
            {
               // d.Due_Date__c = pm.Due_Date__c.addDays(30); 
               d.Due_Date__c = d.Invoice_Date__c.addDays(10);
            }
            d.Demand_Status__c = 'Raised';
            d.Customer_Name__c = pm.Quotation__r.Booking__r.Primary_Applicant_Title__c + ' ' + pm.Quotation__r.Booking__r.Primary_Applicant_Name__c;
            d.Customer_Mobile__c = pm.Quotation__r.Booking__r.Primary_Applicant_Mobile__c;
            d.Customer_Email__c = pm.Quotation__r.Booking__r.Primary_Applicant_Email__c;
            system.debug('DemandList: '+d);
            
            if (pm.Quotation__r.Booking__r.Project__r.Last_Demand_No__c != null) {
                d.Invoice_Number__c = pm.Quotation__r.Booking__r.Project__r.Name + '-' + (pm.Quotation__r.Booking__r.Project__r.Last_Demand_No__c + 1);
            } else {
                if (pm.Quotation__r.Booking__r.Project__r.Starting_Demand_No__c != null) {
                    d.Invoice_Number__c = pm.Quotation__r.Booking__r.Project__r.Name + '-' + (pm.Quotation__r.Booking__r.Project__r.Starting_Demand_No__c + 1);
                } else {
                    d.Invoice_Number__c = pm.Quotation__r.Booking__r.Project__r.Name + '-1';
                }
            }
            
            for (Integer i = 1; i <= 5; i++) {
                if ((String) pm.get('Charge_Bucket_' + i + '__c') != null && String.isNotBlank((String) pm.get('Charge_Bucket_' + i + '__c'))) {
                    if (((String) pm.get('Charge_Bucket_' + i + '__c')).equalsIgnoreCase('Agreement Value')) {
                        List<TDS_Detail__c> getTDSList = getTDSDetails();
                        if(getTDSList != null){
                            if((Decimal) pm.get('Charge_Bucket_' + i + '_Amount__c') > pm.Quotation__r.Booking__r.Project__r.Threshold_Amount__c){
                                d.TDS_Value_Demanded__c = (((Decimal) pm.get('Charge_Bucket_' + i + '_Amount__c') * getTDSList[0].TDS_percentage__c) / 100).setScale(0, RoundingMode.Half_Up);
                                d.Agreement_Value_Demanded__c = ((Decimal) pm.get('Charge_Bucket_' + i + '_Amount__c')) - d.TDS_Value_Demanded__c;
                            }else{
                                d.Agreement_Value_Demanded__c = (Decimal) pm.get('Charge_Bucket_' + i + '_Amount__c');
                            }
                        }else{
                            d.Agreement_Value_Demanded__c = (Decimal) pm.get('Charge_Bucket_' + i + '_Amount__c');
                        }
                        d.Agreement_Value_Tax_Demanded__c = (Decimal) pm.get('Charge_Bucket_' + i + '_Total_Tax__c');
                        d.Total_Amount_Demanded__c = (Decimal) pm.get('Charge_Bucket_' + i + '_Amount__c');
                        d.Total_Tax_Demanded__c = (Decimal) pm.get('Charge_Bucket_' + i + '_Total_Tax__c');
                    } else if (((String) pm.get('Charge_Bucket_' + i + '__c')).equalsIgnoreCase('Statutory Charges')) {
                        d.Statutory_Charges_Demanded__c = (Decimal) pm.get('Charge_Bucket_' + i + '_Amount__c');
                        d.Statutory_Charges_Tax_Demanded__c = (Decimal) pm.get('Charge_Bucket_' + i + '_Total_Tax__c');
                    } else if (((String) pm.get('Charge_Bucket_' + i + '__c')).equalsIgnoreCase('Other Charges')) {
                        d.Other_Charges_Demanded__c = (Decimal) pm.get('Charge_Bucket_' + i + '_Amount__c');
                        d.Other_Charges_Tax_Demanded__c = (Decimal) pm.get('Charge_Bucket_' + i + '_Total_Tax__c');
                    }
                }
            }
            
            try {
                insert d;
                update pm;
                
                List<Demand__c> demandList = [Select Id, Booking__c,Booking__r.Primary_Applicant_Name__c,Name, /*Receipt_Signed_by__c,*/
                                              Booking__r.Unit__r.Name,Booking__r.Project__r.Name,Booking__r.Tower__r.Name,
                                              PublicLink__c, PublicLink_Created__c
                                              from Demand__c where Id =: d.Id];
                system.debug('demandList: '+demandList);
                
                
               /* Blob body;
                system.debug('invoiceDate: '+d.Invoice_Date__c);
                PageReference pageRef2 = new PageReference('/apex/Ex_PrintDemandPDF');
                pageRef2.getParameters().put('bid', d.Booking__c);
                pageRef2.getParameters().put('invoiceDate', String.valueOf(d.Invoice_Date__c));
                pageRef2.getParameters().put('dueDate', String.valueOf(d.Due_Date__c));
                pageRef2.getParameters().put('milestoneName', d.Milestone_Name__c);
                pageRef2.getParameters().put('AmountDemand', String.valueOf(d.Total_Amount_Demanded__c));
                pageRef2.getParameters().put('AmountDemandTax', String.valueOf(d.Total_Tax_Demanded__c));
              //  pageRef2.getParameters().put('ReceiptSigned', String.valueOf(d.Receipt_Signed_by__c));

                system.debug('pageRef2.getContentAsPDF::::'+pageRef2.getContentAsPDF());
              
                try {
                    // returns the output of the page as a PDF
                    if (!test.isRunningTest()) {
                        body = pageRef2.getContentAsPDF();
                        system.debug('body::::'+body);
                        //body = Blob.valueOf('Some Text');
                    } else {
                        body = Blob.valueOf('Some Text');
                    }
                } catch (VisualforceException e) {
                    system.debug('Error: ' + e.getMessage());
                    body = Blob.valueOf('Some Text');
                }                  
                
                ContentVersion objCV = new ContentVersion();
                objCV.Title = 'Demand of ' + demandList[0].Booking__r.Primary_Applicant_Name__c + ' for ' + demandList[0].Booking__r.Unit__r.Name + ' from ' + demandList[0].Booking__r.Project__r.Name + ' - ' + demandList[0].Booking__r.Tower__r.Name;
                objCV.PathOnClient = d.Booking__r.Name + '.pdf';
                objCV.VersionData = body;
                objCV.ContentLocation = 'S';
                objCV.Description = 'Demand for: ' + d.Booking__r.Name;
                insert objCV;
                
                objCV = [SELECT Id, Title,ContentDocumentId from ContentVersion where Id =: objCV.Id];
                
                ContentDocumentLink cDe = new ContentDocumentLink();
                cDe.ContentDocumentId = objCV.ContentDocumentId;
                cDe.LinkedEntityId = d.Id;
                cDe.Visibility = 'AllUsers';
                insert cDe;
                system.debug('cDe::: ' + cDe);
                ContentDistribution cd = new ContentDistribution();
                if(objCV != null) {
                    cd.Name = objCV.Title;
                    cd.ContentVersionId = objCV.id;
                    cd.PreferencesAllowViewInBrowser = true;      
                    cd.PreferencesLinkLatestVersion = true;
                    cd.PreferencesNotifyOnVisit = false;
                    cd.PreferencesPasswordRequired = false;
                    cd.PreferencesAllowOriginalDownload = true;
                    insert cd;   
                    system.debug('cd'+cd);
                    
                    cd = [SELECT Id, ContentDownloadUrl, DistributionPublicUrl FROM ContentDistribution WHERE Id =: cd.Id LIMIT 1];
                    system.debug('DistributionPublicUrl: '+cd.DistributionPublicUrl);
                }
                List<Demand__c> demandUpdateList = new List<Demand__c>();
                for(Demand__c i: demandList) {
                    if(String.isNotBlank(cd.DistributionPublicUrl)){
                        i.PublicLink__c = cd.DistributionPublicUrl;
                        i.PublicLink_Created__c = true;
                    }
                    demandUpdateList.add(i);
                }
                system.debug('demandUpdateList::::'+ demandUpdateList);
                if(!demandUpdateList.isEmpty() && demandUpdateList != null) {
                    update demandUpdateList;
                }*/
                
                
                if(onAccountBalance > 0) {
                    Set<Id> rIdSet = getOnAccountBalanceReceipts(pm.Quotation__r.Booking__c);
                    
                    if(rIdSet != null && !rIdSet.isEmpty()) {
                        Ex_ReceiptHandlerServices.receiptApporation(rIdSet);
                    }
                }
                
            } catch (Exception ex) {
                system.debug('Error: ' + ex.getMessage());
            }
        }
    }

  
    
    public static Decimal getOnAccountBalance(Id bId) {
        Decimal onAccountBalance = 0;
        List<Receipt__c> rList = [Select Id, Name, On_Account_Money__c from Receipt__c where Receipt_Status__c = 'UnProcessed' AND On_Account_Money__c > 0
                                  AND Booking__c =: bId ORDER BY Receipt_Date__c ASC];
        
        if(rList != null) {
            for(Receipt__c r: rList) {
                onAccountBalance += r.On_Account_Money__c;
            }
        }
        return onAccountBalance;
    }
    
    public static Set<Id> getOnAccountBalanceReceipts(Id bId) {
        Set<Id> rIdSet = new Set<Id>();
        List<Receipt__c> rList = [Select Id, Name, On_Account_Money__c from Receipt__c where Receipt_Status__c = 'UnProcessed' AND On_Account_Money__c > 0
                                  AND Booking__c =: bId ORDER BY Receipt_Date__c ASC];
        
        if(rList != null) {
            for(Receipt__c r: rList) {
                rIdSet.add(r.Id);
            }
        }
        return rIdSet;
    }
    
    public static List<TDS_Detail__c> getTDSDetails(){
        Date cDate = System.today();
        List<TDS_Detail__c> tds = new List<TDS_Detail__c>();
        tds = [Select Id, TDS_Percentage__c from TDS_Detail__c where TDS_Percentage__c != null AND (Start_Date__c <=: cDate AND (End_Date__c >=: cDate OR End_Date__c = null))];
        if(tds != null){
            return tds;
        }else{
            return null;
        }
        
    }
    
}