public with sharing class OrderController {
    @AuraEnabled(cacheable=true)
    public static List<Product2> getProducts() {
        return [SELECT Id, Name, precoMoeda__c FROM Product2 WHERE IsActive = true];
    }

    @AuraEnabled
    public static void saveOrder(Map<String, Object> orderDetails) {
        Order__c order = new Order__c();
        order.AccountId__c = (String) orderDetails.get('accountId');
        order.ModoDePagamento__c = (String) orderDetails.get('paymentMode');
        order.Status__c = 'Esperando Pagamento';
        //order.ValorTotalPedido__c = (Decimal) orderDetails.get('totalValue');
        insert order;

        List<OrderItem__c> orderItems = new List<OrderItem__c>();
        List<Map<String, Object>> items = (List<Map<String, Object>>) orderDetails.get('items');
        for (Map<String, Object> item : items) {
            OrderItem__c orderItem = new OrderItem__c();
            orderItem.Pedido__c = order.Id;
            orderItem.Produto__c = (String) item.get('productId');
            orderItem.valorItem__c = (Decimal) item.get('unitPrice');
            orderItems.add(orderItem);
        }
        insert orderItems;

        if (order.ModoDePagamento__c == 'Cartão') {
            order.Status__c = 'Aprovado';
            update order;
        }
    }
}