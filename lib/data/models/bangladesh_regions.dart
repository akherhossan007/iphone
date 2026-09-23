class BangladeshRegions {
  static const List<String> divisions = [
    'Dhaka',
    'Chattogram',
    'Rajshahi',
    'Khulna',
    'Barishal',
    'Sylhet',
    'Rangpur',
    'Mymensingh',
  ];

  static const Map<String, List<String>> districtsByDivision = {
    'Dhaka': ['Dhaka', 'Gazipur', 'Narayanganj', 'Tangail', 'Faridpur', 'Manikganj', 'Munshiganj', 'Narsingdi', 'Kishoreganj'],
    'Chattogram': ['Chattogram', 'Cox\'s Bazar', 'Cumilla', 'Feni', 'Brahmanbaria', 'Noakhali', 'Chandpur'],
    'Rajshahi': ['Rajshahi', 'Bogura', 'Pabna', 'Sirajganj', 'Naogaon', 'Natore', 'Chapai Nawabganj', 'Joypurhat'],
    'Khulna': ['Khulna', 'Jashore', 'Kushtia', 'Satkhira', 'Jhenaidah', 'Bagerhat', 'Chuadanga', 'Magura', 'Meherpur', 'Narail'],
    'Barishal': ['Barishal', 'Bhola', 'Patuakhali', 'Pirojpur', 'Jhalokati', 'Barguna'],
    'Sylhet': ['Sylhet', 'Moulvibazar', 'Habiganj', 'Sunamganj'],
    'Rangpur': ['Rangpur', 'Dinajpur', 'Kurigram', 'Gaibandha', 'Nilphamari', 'Panchagarh', 'Thakurgaon', 'Lalmonirhat'],
    'Mymensingh': ['Mymensingh', 'Jamalpur', 'Netrokona', 'Sherpur'],
  };

  static const Map<String, List<String>> upazilasByDistrict = {
    'Dhaka': ['Gulshan', 'Banani', 'Dhanmondi', 'Uttara', 'Mirpur', 'Mohammadpur', 'Badda', 'Motijheel', 'Old Dhaka', 'Savar', 'Keraniganj', 'Dohar', 'Dhamrai'],
    'Gazipur': ['Sadar', 'Tongi', 'Kaliakair', 'Kapasia', 'Sreepur'],
    'Narayanganj': ['Sadar', 'Fatullah', 'Siddhirganj', 'Bandar', 'Rupganj', 'Sonargaon'],
    'Chattogram': ['Kotwali', 'Panchlaish', 'Agrabad', 'Halishahar', 'Khulshi', 'Nasirabad', 'Sitakunda', 'Hathazari'],
  };
}
