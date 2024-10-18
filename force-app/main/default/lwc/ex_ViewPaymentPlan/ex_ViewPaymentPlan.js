import { LightningElement,api,track,wire } from 'lwc';
import getPaymentMilestone from '@salesforce/apex/ex_ViewPaymentPlanController.getPaymentMilestone';
import getPaymentScheme from '@salesforce/apex/ex_ViewPaymentPlanController.getPaymentScheme';

export default class Ex_ViewPaymentPlan extends LightningElement {
    @api booking;
    @api PaymentSchemeName;
    @api pmList = [];
    @track totalMilestonePercentage = 0;
    @track chargeBucketAmount = 0;
    @track chargeBucketTotalTax = 0;
    @track newTotalAmount = 0;
    @track chargeBucketAmountStr;
    @track chargeBucketTotalTaxStr;
    @track newTotalAmountStr;
    @track totalMilestonePercentageStr;
    
    @wire(getPaymentScheme,({recId: '$booking'})) getName({data}){
        //console.log('BookId is::'+this.booking);
        if(data){
            console.log('Parent comp data for getPaymentScheme is'+JSON.stringify(data))
            if(data != null)
                this.PaymentSchemeName = data;
            else{
                this.PaymentSchemeName = 'No Payment Plan Present on Cost Sheet';
            }
        }
    }

    //fetchPaymentDetails(BookId){
    @wire(getPaymentMilestone,({recId: '$booking'})) getMilestone({data,error}){
        //getPaymentMilestone({recId: this.BookId})
        //.then((result) => {
        if(data){
            this.PaymentMilestoneList = data;
            console.log('PaymentMilestoneList = ' + JSON.stringify(this.PaymentMilestoneList));
            this.PaymentMilestoneList = this.PaymentMilestoneList.map(item => ({ ...item, TotalAmount: this.currencyFormat(item.Charge_Bucket_1_Amount__c + item.Charge_Bucket_1_Total_Tax__c),chargeBucketAmount: this.currencyFormat(item.Charge_Bucket_1_Amount__c),chargeBucketTotalTax : this.currencyFormat(item.Charge_Bucket_1_Total_Tax__c)}))
            console.log('PaymentMilestoneList = ' + JSON.stringify(this.PaymentMilestoneList));
            for(let i = 0; i < this.PaymentMilestoneList.length; i++){
                const pmRecord = {
                    Id : '',
                    milestoneName : '',
                    percentage : '',
                    amount : '',
                    tax : '',
                    totalAmountWithTax: ''
                }
                console.log('this.PaymentMilestoneList.length: '+this.PaymentMilestoneList.length);
                pmRecord.Id = this.PaymentMilestoneList[i].Id;
                pmRecord.milestoneName = this.PaymentMilestoneList[i].Milestone_Name__c;
                pmRecord.percentage = this.percentageFormat(parseFloat(this.PaymentMilestoneList[i].Charge_Bucket_1_Percentage__c));
                pmRecord.amount = this.currencyFormat(parseFloat(this.PaymentMilestoneList[i].Charge_Bucket_1_Amount__c));
                pmRecord.tax = this.currencyFormat(parseFloat(this.PaymentMilestoneList[i].Charge_Bucket_1_Total_Tax__c));
                pmRecord.totalAmountWithTax = this.currencyFormat(parseFloat(this.PaymentMilestoneList[i].Charge_Bucket_1_Amount__c + this.PaymentMilestoneList[i].Charge_Bucket_1_Total_Tax__c));
                console.log('pmRecord.: '+JSON.stringify(pmRecord));
                this.pmList.push(pmRecord);
                
                this.chargeBucketAmount += parseFloat(this.PaymentMilestoneList[i].Charge_Bucket_1_Amount__c);
                this.chargeBucketTotalTax += parseFloat(this.PaymentMilestoneList[i].Charge_Bucket_1_Total_Tax__c);
                this.newTotalAmount += parseFloat(this.PaymentMilestoneList[i].Charge_Bucket_1_Amount__c) + parseFloat(this.PaymentMilestoneList[i].Charge_Bucket_1_Total_Tax__c);
                this.totalMilestonePercentage += this.percentageCov(this.PaymentMilestoneList[i].Charge_Bucket_1_Percentage__c);
    
            }
            this.totalMilestonePercentage = this.percentageCov(this.totalMilestonePercentage);
            console.log('pmList: '+this.pmList);
            console.log('pmList Length: '+this.pmList.length);
            this.chargeBucketAmountStr = this.currencyFormat(parseFloat(this.chargeBucketAmount));
            console.log('this.chargeBucketAmountStr: '+this.chargeBucketAmountStr);
            this.chargeBucketTotalTaxStr = this.currencyFormat(parseFloat(this.chargeBucketTotalTax));
            console.log('this.chargeBucketTotalTaxStr'+this.chargeBucketTotalTaxStr);
            this.newTotalAmountStr = this.currencyFormat(parseFloat((this.newTotalAmount)));
            this.totalMilestonePercentageStr = this.percentageFormat(parseFloat(this.totalMilestonePercentage));
        }else if(error){
            this.error = error;
            console.log('Child component getPaymentMilestone() error is::'+this.error);
        }
    }
    currencyFormat(amt){     
        const formattedAmount = amt.toLocaleString('en-IN', {
            style: 'decimal',
            maximumFractionDigits: 2,
        });
        console.log('formattedAmount -- ',formattedAmount);
        return formattedAmount + '/-';  
    }
    percentageFormat(amt){     
        const formattedAmount = amt.toLocaleString('en-IN', {
        style: 'decimal',
        maximumFractionDigits: 2,
        });
        console.log('formattedAmount -- ',formattedAmount);
        return formattedAmount + '%';  
    }
    percentageCov(amt){     
        const formattedAmount = amt.toLocaleString('en-IN', {
        style: 'decimal',
        maximumFractionDigits: 2,
        });
        console.log('formattedAmount -- ',formattedAmount);
        return Number(formattedAmount);  
    }
      
}