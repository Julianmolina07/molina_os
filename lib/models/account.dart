enum AccountType {
  bank,
  digitalWallet,
  creditCard,
  cash,
}
enum AccountOwner {
  self,
  other,
}
class Account {
  final String id;
  final String name;
  final AccountType type;
  final String currency;
  final AccountOwner legalOwner;
  final AccountOwner economicResponsible;
  final bool active;
  const Account({
    required this.id,
    required this.name,
    required this.type,
    this.currency = 'COP',
    this.legalOwner = AccountOwner.self,
    this.economicResponsible = AccountOwner.self,
    this.active = true,
  });
}