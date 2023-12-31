public with sharing class InvoiceTrigger_HDL {
    public static boolean skipsalesInvoiceUpdate = false;
    public InvoiceTrigger_HDL(){
        
    }
    public void OnAfterInsert(buildertek__Billings__c[] newInvoiceList, Map<ID, buildertek__Billings__c> newInvoiceMap){ 
        Set<Id> invoiceIds = new Set<Id>();
        for (buildertek__Billings__c invoice : newInvoiceList) {
            invoiceIds.add(invoice.Id);
        }
        if (invoiceIds.size() > 0) {
            List<buildertek__Finance_Transaction__c> transactionList = [SELECT Id, Name, buildertek__Sales_Invoice_AR__c FROM buildertek__Finance_Transaction__c WHERE buildertek__Payable_Invoice_AP__c IN: invoiceIds];
            for (buildertek__Finance_Transaction__c fTransaction : transactionList) {
                fTransaction.buildertek__Amount__c = newInvoiceMap.get(fTransaction.buildertek__Sales_Invoice_AR__c).buildertek__Total_Amount_Tax__c;
                fTransaction.buildertek__Credit_Amount__c = newInvoiceMap.get(fTransaction.buildertek__Sales_Invoice_AR__c).buildertek__Total_Amount_Tax__c;
            }
            if (transactionList.size() > 0) {
                update transactionList;
            }
        }
    }

    public void OnBeforeInsert(buildertek__Billings__c[] updatedInvoiceList){ 
        for(buildertek__Billings__c inv : updatedInvoiceList){ 
            if(inv.buildertek__Terms__c == 'Due on Receipt'){
            inv.buildertek__Due_Date__c = Date.today();
            }if(inv .buildertek__Invoiced_Date__c != null && inv.buildertek__Terms__c != 'Due on Receipt'){
                if(inv.buildertek__Terms__c == 'Net 10'){
                    inv.buildertek__Due_Date__c = inv .buildertek__Invoiced_Date__c + 10;
                }else if(inv.buildertek__Terms__c == 'Net 15'){
                    inv.buildertek__Due_Date__c = inv.buildertek__Invoiced_Date__c + 15;
                }else if(inv.buildertek__Terms__c == 'Net 30'){
                    inv.buildertek__Due_Date__c = inv.buildertek__Invoiced_Date__c + 30;
                }else if(inv.buildertek__Terms__c == 'Net 60'){
                    inv.buildertek__Due_Date__c = inv.buildertek__Invoiced_Date__c + 60;
                }
            }
            
        } 
       
    }
    // public void onbeforeUpdate(buildertek__Billings__c[] updatedInvoiceList, Map<ID, buildertek__Billings__c> oldInvoiceMap){ 
    //      for(buildertek__Billings__c inv : updatedInvoiceList){ 
    //          if(inv.buildertek__Terms__c == 'Due on Receipt' && inv.buildertek__Due_Date__c != null){
    //             inv.buildertek__Due_Date__c = Date.today();
    //         }if(inv.buildertek__Invoiced_Date__c != null && oldInvoiceMap.get(inv.Id).buildertek__Invoiced_Date__c != inv.buildertek__Invoiced_Date__c && inv.buildertek__Terms__c != 'Due on Receipt'){
    //             if(inv.buildertek__Terms__c == 'Net 10'){
    //                 inv.buildertek__Due_Date__c = inv.buildertek__Invoiced_Date__c + 10;
    //             }else if(inv.buildertek__Terms__c == 'Net 15'){
    //                 inv.buildertek__Due_Date__c = inv.buildertek__Invoiced_Date__c + 15;
    //             }else if(inv.buildertek__Terms__c == 'Net 30'){
    //                 inv.buildertek__Due_Date__c = inv.buildertek__Invoiced_Date__c + 30;
    //             }else if(inv.buildertek__Terms__c == 'Net 60'){
    //                 inv.buildertek__Due_Date__c = inv.buildertek__Invoiced_Date__c + 60;
    //             }
    //         }
             
    //      } 
       
    // }
    public void onBeforeUpdate(buildertek__Billings__c[] oldInvoiceList, buildertek__Billings__c[] newInvoiceList, Map<ID, buildertek__Billings__c> oldInvoiceMap , Map<ID, buildertek__Billings__c> newInvoiceMap){ 
      
    //    List<buildertek__Receipt__c> ReceiptList= [Select Id, Name , buildertek__Billing__c From buildertek__Receipt__c WHERE buildertek__Billing__c=: newInvoiceMap.keySet()];
    //    for(buildertek__Billings__c inv : newInvoiceList){ 
    //        if(!ReceiptList.isEmpty()){
    //             // if(inv.buildertek__Status__c != oldInvoiceMap.get(inv.Id).buildertek__Status__c || inv.buildertek__Tax_Rate__c != oldInvoiceMap.get(inv.Id).buildertek__Tax_Rate__c || inv.buildertek__Terms__c != oldInvoiceMap.get(inv.Id).buildertek__Terms__c || inv.buildertek__Due_Date__c != oldInvoiceMap.get(inv.Id).buildertek__Due_Date__c || inv.buildertek__Invoiced_Date__c != oldInvoiceMap.get(inv.Id).buildertek__Invoiced_Date__c ) {
    //                 inv.addError('You cannot update this Sales Invoice because there is a Receipt associated with it.  If you would like to change this Sales Invoice, please remove the Receipt first.');
    //             // }
    //         }
    //     }


    // When Budget add to sales invoice it will create new Budget line ------------------------------------
    System.debug('Inside onBeforeUpdate');
        Map<String, buildertek__Budget_Item__c> MapToUpte = new  Map<String, buildertek__Budget_Item__c>();
        String BLGroupID;
        list<buildertek__Budget_Line_Group__c> BLGroup = [SELECT Id, Name FROM buildertek__Budget_Line_Group__c WHERE Name LIKE '%Sales Invoice%'];
            // Check is Buddget line group with name sales invoice is avialable or on if not abailabe it will create new
            if (BLGroup.size() == 0){
                System.debug('Create Budgt Line Group');
                buildertek__Budget_Line_Group__c BLG = new buildertek__Budget_Line_Group__c(Name = 'Sales Invoice');
                insert BLG;

                BLGroupID = BLG.Id;
            } else {
                BLGroupID = BLGroup[0].Id;
            }
        for(buildertek__Billings__c sl : newInvoiceList){
            if(oldInvoiceMap.get(sl.Id).buildertek__Budget__c == null && sl.buildertek__Budget__c != oldInvoiceMap.get(sl.Id).buildertek__Budget__c){
                    buildertek__Budget_Item__c BL = new buildertek__Budget_Item__c();
                    BL.Name = sl.Name.length() > 67 ? (sl.Name.substring(0,66) + ' budget line') : (sl.name + ' budget line');
                    // BL.Name = sl.Name + ' budget line';
                    BL.buildertek__Unit_Price__c = 0;
                    BL.buildertek__Sales_Invoice__c = sl.buildertek__Total_Amount_Tax__c;
                    BL.buildertek__Quantity__c = 1;
                    BL.buildertek__Group__c = BLGroupID;
                    BL.buildertek__Budget__c = sl.buildertek__Budget__c;
                    MapToUpte.put(sl.Id, BL);
            }
        }
        if(MapToUpte.size() > 0){
            insert MapToUpte.values();
            System.debug('BLlistToInsert => ' + MapToUpte);

        for(buildertek__Billings__c slToUpdate : newInvoiceList){
            if(oldInvoiceMap.get(slToUpdate.Id).buildertek__Budget__c == null && slToUpdate.buildertek__Budget__c != oldInvoiceMap.get(slToUpdate.Id).buildertek__Budget__c){
                    System.debug('Sales Invoice name : '+ slToUpdate.Name +' Budget Line Id :  '+ MapToUpte.get(slToUpdate.Id).Id);
                    slToUpdate.buildertek__BT_Budget_Line__c = MapToUpte.get(slToUpdate.Id).Id;
                }
            }
        } // ===========================================================================


        // Remove Budget when Budget Line is removed from Sales invoice --------------------------------------
        for(buildertek__Billings__c Sl : newInvoiceList){
            if(!skipsalesInvoiceUpdate && Sl.buildertek__BT_Budget_Line__c == null && oldInvoiceMap.get(Sl.id).buildertek__BT_Budget_Line__c != null && Sl.buildertek__Budget__c != null){
                Sl.buildertek__Budget__c = null;
            }
        } // ===========================================================================

    }

    // If user remove budget line from sales invoice it will delete sales invoice in perticular sales invoicce auto created from Code.
    public void DeleteBudgetLine(buildertek__Billings__c[] oldInvoiceList, buildertek__Billings__c[] newInvoiceList, Map<ID, buildertek__Billings__c> oldInvoiceMap , Map<ID, buildertek__Billings__c> newInvoiceMap){
            // System.debug('Inside Delete Budget line From Sales Invoice');
            list<buildertek__Budget_Item__c> BudgetLineToDELETE = new list<buildertek__Budget_Item__c>();
            list<buildertek__Billings__c> SaleInvoiceToUpdate = new list<buildertek__Billings__c>();
            Set<Id> BudgetLineToDELETESet = new Set<Id>();
            for(buildertek__Billings__c Sl : newInvoiceList){
                if(Sl.buildertek__BT_Budget_Line__c == null && oldInvoiceMap.get(Sl.id).buildertek__BT_Budget_Line__c != null){
                    String BlName = sl.Name + ' budget line';
                    list<buildertek__Budget_Item__c> BLlist = [SELECT Id, Name FROM buildertek__Budget_Item__c WHERE Id =: oldInvoiceMap.get(Sl.id).buildertek__BT_Budget_Line__c AND Name =: BlName LIMIT 1];
                    for(buildertek__Budget_Item__c bl : BLlist){
                        BudgetLineToDELETESet.add(bl.Id);
                        }
                    }
                }
                if(!skipsalesInvoiceUpdate && BudgetLineToDELETESet.size() > 0){
                    System.debug('Budget line Is going to Delete From Sales Invoice');
                    for(buildertek__Budget_Item__c BL : [SELECT Id, Name FROM buildertek__Budget_Item__c WHERE Id IN: BudgetLineToDELETESet]){
                        BudgetLineToDELETE.add(BL);
                    }
                    delete BudgetLineToDELETE;
                }
    }
    
    public void OnAfterUpdate(buildertek__Billings__c[] oldInvoiceList, buildertek__Billings__c[] updatedInvoiceList, Map<ID, buildertek__Billings__c> InvoiceMap, Map<Id, buildertek__Billings__c> oldInvoiceMap){
        SET<Id> changerOderIdSet = new SET<Id>();
        SET<Id> budgetIdSet = new SET<Id>();
        SET<Id> budgetChangerOderIdSet = new SET<Id>();
        decimal totalAmount = 0;
        Map<String, String> changeOrderMap = new Map<String, String>();
        Map<String, Decimal> budgetMap = new Map<String, Decimal>();
        List<buildertek__Budget__c> budgetListToUpdate = new List<buildertek__Budget__c>();
        Set<Id> invoiceIds = new Set<Id>();
        Set<Id> removeInvoiceId = new Set<Id>();

        for(buildertek__Billings__c inv : updatedInvoiceList){ 
            changerOderIdSet.add(inv.buildertek__Change_Order__c); 
            
            if (inv.buildertek__Total_Amount_Tax__c != oldInvoiceMap.get(inv.Id).buildertek__Total_Amount_Tax__c) {
                invoiceIds.add(inv.Id);
            }
            if(oldInvoiceMap.get(inv.Id).buildertek__BT_Finance_Transaction__c != null && inv.buildertek__BT_Finance_Transaction__c == null){
                removeInvoiceId.add(inv.Id);
            }
        } 

        if (removeInvoiceId.size() > 0) {
            List<buildertek__Finance_Transaction__c> transactionList = [SELECT Id, Name, buildertek__Sales_Invoice_AR__c FROM buildertek__Finance_Transaction__c WHERE buildertek__Sales_Invoice_AR__c IN: removeInvoiceId];
            for (buildertek__Finance_Transaction__c fTransaction : transactionList) {
                fTransaction.buildertek__Sales_Invoice_AR__c = null;
            }
            if (transactionList.size() > 0) {
                update transactionList;
            }

        }
        system.debug('changerOderIdSet --------> '+changerOderIdSet);
        List<buildertek__Change_Order__c> changeOrderList = new List<buildertek__Change_Order__c>();
        if(Schema.sObjectType.buildertek__Change_Order__c.fields.Id.isAccessible()&&
             Schema.sObjectType.buildertek__Change_Order__c.fields.Name.isAccessible() &&
             Schema.sObjectType.buildertek__Change_Order__c.fields.buildertek__Budget__c.isAccessible()){
                     changeOrderList = [SELECT Id,
                                        Name,
                                        buildertek__Budget__c
                                        FROM buildertek__Change_Order__c
                                        WHERE Id IN: changerOderIdSet];
             }
        for(buildertek__Change_Order__c CO : changeOrderList){
            budgetIdSet.add(CO.buildertek__Budget__c);    
        } 
        List<buildertek__Change_Order__c> budgetChangeOrderList = new List<buildertek__Change_Order__c>();
         if(Schema.sObjectType.buildertek__Change_Order__c.fields.Id.isAccessible()&&
             Schema.sObjectType.buildertek__Change_Order__c.fields.Name.isAccessible() &&
             Schema.sObjectType.buildertek__Change_Order__c.fields.buildertek__Budget__c.isAccessible()){
                    budgetChangeOrderList = [SELECT Id,
                                            Name,
                                            buildertek__Budget__c
                                            FROM buildertek__Change_Order__c
                                            WHERE buildertek__Budget__c IN: budgetIdSet];
             }
        
        
        system.debug('changeOrderList --------> '+budgetChangeOrderList);
        system.debug('changeOrderList Size --------> '+budgetChangeOrderList.size());
        for(buildertek__Change_Order__c changeOrder : budgetChangeOrderList){
            budgetChangerOderIdSet.add(changeOrder.Id);
            changeOrderMap.put(changeOrder.Id, changeOrder.buildertek__Budget__c);
        } 
        List<buildertek__Billings__c> invoiceList = new List<buildertek__Billings__c>();
        if(Schema.sObjectType.buildertek__Billings__c.fields.Id.isAccessible()&&
             Schema.sObjectType.buildertek__Billings__c.fields.Name.isAccessible() &&
             Schema.sObjectType.buildertek__Billings__c.fields.buildertek__Change_Order__c.isAccessible() &&
             Schema.sObjectType.buildertek__Billings__c.fields.buildertek__Total_Amount_Tax__c.isAccessible() &&
             Schema.sObjectType.buildertek__Change_Order__c.fields.buildertek__Budget__c.isAccessible()){
              invoiceList = [SELECT Id,
                                    Name,
                                    buildertek__Change_Order__c,
                                    buildertek__Change_Order__r.buildertek__Budget__c,
                                    buildertek__Total_Amount_Tax__c
                                    FROM buildertek__Billings__c
                                    WHERE buildertek__Change_Order__c IN: budgetChangerOderIdSet];
             }                                 
        system.debug('invoiceList --------> '+invoiceList);
        system.debug('invoiceList Size --------> '+invoiceList.size());
        for(buildertek__Billings__c invoice : invoiceList){ 
            //totalAmount += invoice.buildertek__Total_Amount_Tax__c;
            if(budgetMap.get(invoice.buildertek__Change_Order__r.buildertek__Budget__c) == null){
                budgetMap.put(invoice.buildertek__Change_Order__r.buildertek__Budget__c, invoice.buildertek__Total_Amount_Tax__c);    
            }else{
               decimal finalTotalAmount = budgetMap.get(invoice.buildertek__Change_Order__r.buildertek__Budget__c) + invoice.buildertek__Total_Amount_Tax__c; 
               budgetMap.put(invoice.buildertek__Change_Order__r.buildertek__Budget__c, finalTotalAmount);
            }
             
        } 
        
       /* List<buildertek__Budget__c> budgetList = [SELECT Id,
                                                         Name,
                                                         buildertek__Invoice_To_Date__c
                                                         FROM buildertek__Budget__c
                                                         WHERE Id IN: budgetIdSet];*/   
                                                         
        for(String budgetId : budgetMap.keySet()){
            if(budgetId != null ){
                if (Schema.sObjectType.buildertek__Budget__c.fields.Id.isUpdateable()
                    && Schema.sObjectType.buildertek__Budget__c.fields.buildertek__Invoice_To_Date__c.isUpdateable()) {
                    buildertek__Budget__c newBudget =  new buildertek__Budget__c();
                    newBudget.Id = budgetId;
                    newBudget.buildertek__Invoice_To_Date__c = budgetMap.get(budgetId);
                    budgetListToUpdate.add(newBudget);    
                }
            }
            
        } 
        if(budgetListToUpdate.size() > 0){
            update budgetListToUpdate;    
        }

        if (invoiceIds.size() > 0) {
            List<buildertek__Finance_Transaction__c> transactionList = [SELECT Id, Name, buildertek__Sales_Invoice_AR__c FROM buildertek__Finance_Transaction__c WHERE buildertek__Sales_Invoice_AR__c IN: invoiceIds];
            for (buildertek__Finance_Transaction__c fTransaction : transactionList) {
                fTransaction.buildertek__Amount__c = InvoiceMap.get(fTransaction.buildertek__Sales_Invoice_AR__c).buildertek__Total_Amount_Tax__c;
                fTransaction.buildertek__Credit_Amount__c = InvoiceMap.get(fTransaction.buildertek__Sales_Invoice_AR__c).buildertek__Total_Amount_Tax__c;
            }
            if (transactionList.size() > 0) {
                update transactionList;
            }
        }

    }
}