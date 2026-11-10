enum UserRole { owner, admin, cashier }

class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.role,
    this.cartId,
  });

  final String id;
  final String name;
  final UserRole role;
  final String? cartId;
}
