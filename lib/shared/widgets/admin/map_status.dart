String mapStatus(String firestoreStatus) {
  switch (firestoreStatus) {
    case 'Dibuat':
      return 'Pending';
    case 'Diproses':
      return 'Diproses';
    case 'Selesai':
      return 'Selesai';
    default:
      return firestoreStatus;
  }
}

String mapStatusToFirestore(String uiStatus) {
  switch (uiStatus) {
    case 'Pending':
      return 'Dibuat';
    case 'Diproses':
      return 'Diproses';
    case 'Selesai':
      return 'Selesai';
    default:
      return uiStatus;
  }
}
