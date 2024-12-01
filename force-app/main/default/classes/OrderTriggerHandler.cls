public class OrderTriggerHandler {
    public static void handleOrderFields(List<Order> orders) {
        // Obter os IDs das contas relacionadas aos pedidos
        Set<Id> accountIds = new Set<Id>();
        for (Order order : orders) {
            if (order.AccountId != null) {
                accountIds.add(order.AccountId);
            }
        }

        // Buscar contratos relacionados a essas contas
        Map<Id, Contract> accountContracts = new Map<Id, Contract>(
            [SELECT Id, AccountId FROM Contract WHERE AccountId IN :accountIds AND Status = 'Draft' LIMIT 1]
        );

        // Variável para armazenar o maior número encontrado nos pedidos
        Integer lastOrderNumber = 0;

        // Obter o maior número já usado no campo Name com formato #0000
        if (Trigger.isInsert) {
            AggregateResult[] results = [SELECT MAX(Name) maxName FROM Order WHERE Name LIKE '#%'];
            if (!results.isEmpty() && results[0].get('maxName') != null) {
                String lastOrderName = String.valueOf(results[0].get('maxName'));
                // Remover o caractere "#" e converter o restante para número
                lastOrderNumber = Integer.valueOf(lastOrderName.replace('#', ''));
            }
        }

        // Iterar pelos pedidos e aplicar as regras
        for (Order order : orders) {
            // Atualizar o status com base no modo de pagamento
            if (Trigger.isInsert || Trigger.isUpdate) {
                if (order.Modo_de_Pagamento__c == 'Cartão' || 
                    order.Modo_de_Pagamento__c == 'Vale Refeição/Vale Alimentação' || 
                    order.Modo_de_Pagamento__c == 'Voucher') {
                    order.Status_Pagamento__c = 'Aprovado';
                    order.Status = 'Aprovado';
                } else {
                    order.Status_Pagamento__c = 'Pagamento Pendente';
                    order.Status = 'Rascunho';
                }
                
            }

            // Atribuir nome incremental apenas em inserção
            if (Trigger.isInsert) {
                lastOrderNumber++;
                // Formatar o número manualmente com zeros à esquerda
                String formattedNumber = '#' + String.valueOf(lastOrderNumber);
                while (formattedNumber.length() < 5) { // Garantir que tenha 4 dígitos após '#'
                    formattedNumber = '#0' + formattedNumber.substring(1);
                }
                order.Name = formattedNumber;
            }

            // Verifica se o EffectiveDate (Data de Vigência) não está preenchido
            if (order.EffectiveDate == null) {
                // Gera uma data aleatória (próximo mês como exemplo)
                order.EffectiveDate = Date.today().addDays(Math.mod(Crypto.getRandomInteger(), 30));
            }

            // Associar o contrato da conta ao pedido
            if (order.ContractId == null && accountContracts.containsKey(order.AccountId)) {
                order.ContractId = accountContracts.get(order.AccountId).Id;
            }
        }
    }
}