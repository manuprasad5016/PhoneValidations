public with sharing class SampleLookupController {
    private final static Integer MAX_RESULTS = 5;

    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> describeSobjects(String searchTerm, List<String> selectedIds) {
        // Prepare results
        String accountIcon = 'standard:account';
        List<Contact> accList = [Select Id from Contact limit 1000];
        List<LookupSearchResult> results = new List<LookupSearchResult>();
        Integer i =0;
        for( Schema.SObjectType temp : Schema.getGlobalDescribe().values())
            {
                Id val = accList[i].Id;
                i++;
                if(temp.getDescribe().getLabel().startsWithIgnoreCase(searchTerm)){
                results.add(new LookupSearchResult(val, 'Account', accountIcon, temp.getDescribe().getLabel(), temp.getDescribe().getName()));
                //Map < String, String > values = new Map < String, String > { 'label' => temp.getDescribe().getLabel(), 'value' => temp.getDescribe().getName() };
                }
            }   
        return results;
    }

    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> apexRuleSearch(String searchTerm, List<String> selectedIds) {
        // Prepare results
        String accountIcon = 'standard:account';
        List<Rule__c> ruleList = [Select Id,Name from Rule__c limit 1000];
        List<LookupSearchResult> results = new List<LookupSearchResult>();
        for( Rule__c temp : ruleList)
            {
                if(temp.Name.startsWithIgnoreCase(searchTerm)){
                results.add(new LookupSearchResult(temp.Id, 'Rule', accountIcon, temp.Name, temp.Name));
                //Map < String, String > values = new Map < String, String > { 'label' => temp.getDescribe().getLabel(), 'value' => temp.getDescribe().getName() };
                }
            }   
        return results;
    }

    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> describeFields(String searchTerm, List<String> selectedIds) {
        // Prepare results
        String accountIcon = 'standard:account';
        List<Contact> accList = [Select Id from Contact limit 1000];
        List<LookupSearchResult> results = new List<LookupSearchResult>();
        Integer i =0;
        Map <String, Schema.SObjectType> mapSobjects = Schema.getGlobalDescribe();
        Map <String, Schema.SObjectField> fieldMap = mapSobjects.get('Account').getDescribe().fields.getMap();
        for( String temp : fieldMap.KeySet())
            {
                Id val = accList[i].Id;
                i++;
                if(temp.startsWithIgnoreCase(searchTerm)){
                results.add(new LookupSearchResult(val, 'Account', accountIcon, temp, temp));
                }
            }   
        return results;
    }

    @AuraEnabled(Cacheable=true)
    //public static List<LookupSearchResult> search(String searchTerm, List<String> selectedIds) {
        public static void search(String searchTerm, List<String> selectedIds) {
     /*   // Prepare query paramters
        searchTerm += '*';

        // Execute search query
        List<List<SObject>> searchResults = [
            FIND :searchTerm
            IN ALL FIELDS
            RETURNING
                Account(Id, Name, BillingCity WHERE id NOT IN :selectedIds),
                Opportunity(Id, Name, StageName WHERE id NOT IN :selectedIds)
            LIMIT :MAX_RESULTS
        ];

        // Prepare results
        List<LookupSearchResult> results = new List<LookupSearchResult>();

        // Extract Accounts & convert them into LookupSearchResult
        String accountIcon = 'standard:account';
        Account[] accounts = (List<Account>) searchResults[0];
        for (Account account : accounts) {
            String subtitle = account.BillingCity == null ? 'Account' : 'Account • ' + account.BillingCity;
            results.add(new LookupSearchResult(account.Id, 'Account', accountIcon, account.Name, subtitle));
        }

        // Extract Opportunities & convert them into LookupSearchResult
        String opptyIcon = 'standard:opportunity';
        Opportunity[] opptys = (List<Opportunity>) searchResults[1];
        for (Opportunity oppty : opptys) {
            results.add(
                new LookupSearchResult(
                    oppty.Id,
                    'Opportunity',
                    opptyIcon,
                    oppty.Name,
                    'Opportunity • ' + oppty.StageName
                )
            );
        }

        // Optionnaly sort all results on title
        results.sort();

        return results;  */
    }

    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> getRecentlyViewed() {
        List<LookupSearchResult> results = new List<LookupSearchResult>();
        // Get recently viewed records of type Account or Opportunity
        List<RecentlyViewed> recentRecords = [
            SELECT Id, Name, Type
            FROM RecentlyViewed
            WHERE Type = 'Account' OR Type = 'Opportunity'
            ORDER BY LastViewedDate DESC
            LIMIT 5
        ];
        // Convert recent records into LookupSearchResult
        for (RecentlyViewed recentRecord : recentRecords) {
            if (recentRecord.Type == 'Account') {
                results.add(
                    new LookupSearchResult(
                        recentRecord.Id,
                        'Account',
                        'standard:account',
                        recentRecord.Name,
                        'Account • ' + recentRecord.Name
                    )
                );
            } else {
                results.add(
                    new LookupSearchResult(
                        recentRecord.Id,
                        'Opportunity',
                        'standard:opportunity',
                        recentRecord.Name,
                        'Opportunity • ' + recentRecord.Name
                    )
                );
            }
        }
        return results;
    }
}