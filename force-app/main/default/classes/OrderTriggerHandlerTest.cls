@isTest
public class OrderTriggerHandlerTest {
    @isTest
    static void testHandleOrderFields() {
        // Criar contas de teste
        List<Account> testAccounts = new List<Account>{
            new Account(Name = 'Conta 1'),
            new Account(Name = 'Conta 2')
        };
        insert testAccounts;

        // Criar contratos para cada conta
        List<Contract> testContracts = new List<Contract>();
        for (Account acc : testAccounts) {
            testContracts.add(new Contract(
                AccountId = acc.Id,
                StartDate = Date.today(),
                ContractTerm = 12,
                Status = 'Draft'
            ));
        }
        insert testContracts;

        // Criar pedidos de teste
        List<Order> testOrders = new List<Order>{
            new Order(
                AccountId = testAccounts[0].Id,
                Modo_de_Pagamento__c = 'Cartão',
                Status = null,
                EffectiveDate = null,
                ContractId = null
            ),
            new Order(
                AccountId = testAccounts[1].Id,
                Modo_de_Pagamento__c = 'Dinheiro',
                Status = null,
                EffectiveDate = null,
                ContractId = null
            )
        };

        // Inserir os pedidos
        insert testOrders;

        // Recuperar os pedidos criados
        List<Order> insertedOrders = [
            SELECT Name, EffectiveDate, Status_Pagamento__c, Status, ContractId 
            FROM Order 
            WHERE Id IN :testOrders
        ];

        // Validações para cada pedido
        for (Order order : insertedOrders) {
            System.assertEquals('Rascunho', order.Status, 'O status inicial deve ser Rascunho');
            System.assertNotEquals(null, order.Name, 'O campo Name deve ser preenchido com um valor incremental');
            System.assertNotEquals(null, order.EffectiveDate, 'O campo EffectiveDate deve ser preenchido');
            System.assertNotEquals(null, order.ContractId, 'O campo ContractId deve ser associado ao contrato da conta');

            if (order.Modo_de_Pagamento__c == 'Cartão') {
                System.assertEquals('Aprovado', order.Status_Pagamento__c, 'O Status_Pagamento__c deve ser "Aprovado" para pagamentos com Cartão');
            } else {
                System.assertEquals('Pagamento Pendente', order.Status_Pagamento__c, 'O Status_Pagamento__c deve ser "Pagamento Pendente" para outros pagamentos');
            }
        }
    }
}