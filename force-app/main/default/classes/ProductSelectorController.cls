public with sharing class ProductSelectorController {
    @AuraEnabled(cacheable=true)
    public static List<Product2> getProducts() {
        return [
            SELECT Id, Name, (SELECT UnitPrice FROM PricebookEntries WHERE IsActive = true LIMIT 1)
            FROM Product2
            WHERE IsActive = true
            ORDER BY Name
        ];
    }
}
