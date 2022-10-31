/* --- models absensi --*/
class AbsenList {        
  final int id;
  final String masuk;
  final String pulang; 
  final int pegawaiID;
  final int machineID;
  final String machineName;  

  AbsenList({
    this.id,
    this.masuk,
    this.pulang,
    this.pegawaiID,
    this.machineID,
    this.machineName,
  }); 

  factory AbsenList.fromJson(Map<String,dynamic> json) {
    return AbsenList(      
      id: json['id'],
      masuk: json['masuk'],
      pulang: json['pulang'],
      pegawaiID: json['pegawai_id'],
      machineID: json['machine_id'],
      machineName: json['machine_name'],      
    );
  }
}