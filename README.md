# Soal Shift Sisop Modul 1 2022

Repository untuk soal shift sisop modul 1 kelompok B07 tahun 2022

## Nomor 1

**register.sh**

Script bash `register.sh` digunakan untuk register user. Data username dan password setiap user akan disimpan ke dalam folder users file `user.txt`. Di awal program terdapat welcome message dan kemudian diminta untuk menginput username seperti pada script di bawah.

```bash
printf "================================\n"
printf "!!!Welcome to register.sh!!!\n"
printf "================================\n"
printf "Input your username: "
read username
```

Kemudian username yang telah diinput, akan dicek terlebih dahulu apakah sudah pernah melakukan register sebelumnya dan apakah username yang diinputkan sudah ada pada file `user.txt`.

```bash
function check_username() {
  local user_exists=0

  for user in $(awk '{ print $1 }' users/user.txt)
  do
    if [ $user == $username ]
    then
      user_exists=1
      break  # exit program if username already exists
    fi
  done

  echo $user_exists
}
```

- Fungsi `check_username()` digunakan untuk mengecek apakah username sudah pernah diinputkan sebelumnya.
- Buat variabel lokal `user_exists` untuk menyimpan ada atau tidaknya username pada file `user.txt` dan kemudian digunakan sebagai return value dari fungsi.
- Looping setiap line di dalam file `user.txt` untuk mengecek ada atau tidaknya username.
- Script `awk '{ print $1 }' users/user.txt` untuk mendapatkan data username dari file `user.txt`.
- Apabila username ditemukan, maka variabel `user_exists` akan bernilai 1 dan looping akan dihentikan.

```bash
if [[ $(check_username) -gt 0 ]]
then
  echo "`date +"%D %H:%M:%S"` REGISTER: ERROR User already exists" >> log.txt
  printf "\n-----------------------------------"
  printf "\nREGISTER: ERROR User already exists"  # if register is fail
  printf "\n-----------------------------------\n"
  exit 0  # exit program if username already exists
fi
```

- Jika return value dari fungsi `check_username` bernilai lebih dari 0, maka akan ditampilkan pesan error. Pesan error juga akan dimasukkan ke dalam file `log.txt` beserta waktu percobaan register.
- Untuk mendapatkan waktu percobaan register, menggunakan `date +"%D %H:%M:%S"`.
- Di akhir _conditional statement_, program akan di-_exit_ karena username sudah pernah melakukan register sebelumnya.

Apabila username belum ada pada file `user.txt`, maka program akan dilanjutkan untuk menginput password.

```bash
printf "Input your password: "
read -s password
```

Kemudian mengecek password apakah telah sesuai dengan ketentuan. Apabila ada yang belum sesuai ketentuan, akan ditampilkan pesan error beserta keterangannya, kemudian user diminta untuk menginput ulang password hingga memenuhi semua syarat.

```bash
until [[ "$password" =~ [A-Z] && "$password" =~ [a-z] && "$password" =~ [0-9] && "$password" != "$username" && ${#password} -ge 8 ]]
do
  printf "\n------------------------------------------------------------"
  if  [[ ! $password =~ [0-9] ]]
  then
    printf "\nERROR: Password must contain at least one number"
  fi
  if [[ ! $password =~ [a-z] ]]
  then
    printf "\nERROR: Password must contain at least one lowercase letter"
  fi
  if [[ ! $password =~ [A-Z] ]]
  then
    printf "\nERROR: Password must contain at least one uppercase letter"
  fi
  if [[ ${#password} -lt 8 ]]
  then
    printf "\nERROR: Password must be at least 8 characters long"
  fi
  if [[ $password == $username ]]
  then
    printf "\nERROR: Password must not be the same as the username"
  fi
  printf "\n------------------------------------------------------------"

  printf "\nPlease input password again: "
  read -s password
done
```

- `"$password" =~ [A-Z]` merupakan syarat bahwa harus terdapat minimal satu huruf _UPPERCASE_ pada password.
- `"$password" =~ [a-z]` merupakan syarat bahwa harus terdapat minimal satu huruf _lowercase_ pada password.
- `"$password" =~ [0-9]` merupakan syarat bahwa harus terdapat minimal satu angka pada password.
- `"$password" != "$username"` merupakan syarat bahwa password tidak boleh sama dengan username yang telah diinputkan.
- `${#password} -ge 8` merupakan syarat bahwa panjang password minimal 8 karakter.

Jika password sudah memenuhi semua syarat, maka data username dan password akan ditambahkan di akhir file `user.txt` pada folder users.

```bash
echo "$username $password" >> ./users/user.txt
```

Data yang telah masuk pada file `user.txt` menandakan bahwa proses register berhasil. Kemudian pesan log akan dimasukkan ke dalam file `log.txt` beserta waktu saat register telah berhasil. Pesan log berhasil register juga akan ditampilkan di terminal.

```bash
echo "`date +"%D %H:%M:%S"` REGISTER: INFO User $username registered successfully" >> log.txt
printf "\n-----------------------------------------------------"
printf "\nREGISTER: INFO User $username registered successfully"
printf "\n-----------------------------------------------------\n"
```

**main.sh**

Script bash `register.sh` digunakan untuk login user. User juga bisa mendownload gambar dari https://loremflickr.com/320/240, serta menampilkan jumlah percobaan login yang pernah dilakukan oleh user (baik berhasil maupun tidak). Di awal program terdapat _welcome message_ dan diminta untuk menginput username beserta password.

```bash
printf "===========================\n"
printf "!!!Welcome to login page!!!\n"
printf "===========================\n"
printf "Input your username: "
read username
printf "Input your password: "
read -s password
```

Kemudian terdapat fungsi untuk mengecek username beserta passwordnya.

```bash
function check_password() {
  local is_correct=1
  data_from_file=$(awk -v var="$username" '$1 ~ var' users/user.txt)
  data_from_input="$username $password"
  if [[ $data_from_file == $data_from_input ]]
  then
    is_correct=$? # return 1 for false
  fi

  echo $is_correct
}
```

- Buat variabel local `is_correct` untuk menyimpan hasil cek password dan digunakan sebagai return value.
- Fungsi `awk -v var="$username" '$1 ~ var' users/user.txt` akan mengecek data user dengan mencari username terlebih dahulu, kemudian mengembalikan satu line data yang berisi username beserta passwordnya. Kemudian disimpan ke dalam variabel bernama `data_from_file`.
- Username dan password yang diinputkan disimpan ke dalam variabel `data_from_input`.
- Kemudian akan dicek username dan password apakah `data_from_file` sama dengan `data_from_input`. `$?` berarti apabila pernyataan sebelumnya benar, maka variabel `is_correct` akan bernilai 0, dan apabila salah akan bernilai 1.

```bash
if [[ $(check_password) == 0 ]]
then
  echo "`date +"%D %T"` LOGIN: INFO User $username logged in" >> log.txt
  printf "\n--------------------------------------"
  printf "\nLOGIN: INFO User $username logged in"  # if log in is fail
  printf "\n--------------------------------------"
else
  echo "`date +"%D %T"` LOGIN: ERROR Failed login attempt on user $username" >> log.txt
  printf "\n---------------------------------------------------------"
  printf "\nLOGIN: ERROR Failed login attempt on user $username"  # if log in is fail
  printf "\n---------------------------------------------------------"
  exit 0  # exit program if username already exists
fi
```

- Jika return value dari fungsi `check_password` bernilai 0, maka proses log in berhasil dan pesan log akan dimasukkan ke dalam file `log.txt` serta ditampilkan di terminal.
- Jika return value dari fungsi `check_password` bernilai selain 0, maka proses log in gagal dan pesan error akan dimasukkan ke dalam file `log.txt` serta ditampilkan di terminal. Kemudian program dihentikan.

Ketika proses log in berhasil maka akan dilanjutkan input sebuah command.

```bash
printf "\nInput command: "
read commnd n
```

- `commnd` merupakan _command_ yang akan dijalankan (`dl` untuk men-_download_ gambar dan `att` untuk menampilkan banyaknya percobaan log in).
- `n` merupakan banyaknya gambar yang akan di-_download_ ketika menginputkan _command_ `dl`.

Kemudian terdapat function untuk men-_download_ gambar dan memunculkan banyaknya percobaan log in.

```bash
function download_image() {
  picture_amount=$n
  time_stamp_for_file_name="`date "+%F"`"
  download_folder_name="${time_stamp_for_file_name}_${username}"

  if [ -d "${download_folder_name}" ]
  then
    rm -rf "${download_folder_name}"
  fi

  mkdir "${download_folder_name}"

  if [ -e "${download_folder_name}.zip" ]
  then
    unzip -P "${password}" "${download_folder_name}.zip" -d "${download_folder_name}"
    rm -rf "${download_folder_name}.zip"
  fi

  cd "${download_folder_name}"
  start_index=`ls | wc -l`

  for((i=1; i<=$picture_amount; i++))
  do
    index=$(($start_index+$i))
    if [[ $index -lt 10 ]]
    then
      wget -cO PIC_0$index https://loremflickr.com/320/240
    else
      wget -cO PIC_$index https://loremflickr.com/320/240
    fi
  done

  zip -P $password ${download_folder_name}.zip *
  mv ${download_folder_name}.zip ..
  cd ..
  rm -rf "${download_folder_name}"
}
```

- Variabel `picture_amount` untuk menyimpan nilai `n` yakni banyaknya gambar yang akan di-_download_.
- Variabel `time_stamp_for_file_name` untuk menyimpan tanggal yang akan digunakan untuk penamaan file.
- Variabel `download_folder_name` untuk menyimpan nama folder.
- Jika folder yang dituju sudah ada sebelumnya, maka akan dihapus terlebih dahulu.
- Kemudian akan dibuat folder baru dengan nama sesuai `download_folder_name`.
- Jika sudah ada file zip dengan nama yang sama, maka akan di-_unzip_ terlebih dahulu kemudian dihapus.
- Kemudian masuk ke dalam folder `download_folder_name` dan menghitung jumlah gambar yang ada di dalam folder tersebut menggunakan `ls | wc -l`.
- Start _download_ dengan index awal melanjutkan jumlah gambar yang sudah ada di dalam folder `download_folder_name`. _Download_ gambar menggunakan `wget -cO nama_gambar https://loremflickr.com/320/240`. `nama_gambar` diubah sesuai format yang diminta, yaitu `PIC_$index`.
- Setelah _download_ selesai, folder di-_zip_ kembali menggunakan password `zip -P $password ${download_folder_name}.zip *`.
- Karena file zip masih berada di direktori `download_folder_name`, maka harus dipindah keluar direktori tersebut menggunakan `mv ${download_folder_name}.zip ..`.
- Setelah itu keluar direktori menggunakan `cd ..` dan hapus folder `download_folder_name` menggunakan `rm -rf "${download_folder_name}"`.

```bash
function login_try() {
  tries=$(awk -v var="$username" '
  /log/ && $0 ~ var { ++n }
  END { print n }' log.txt)

  echo $tries
}
```

- Hitung banyaknya percobaan log in menggunakan `awk -v var="$username" '/log/ && $0 ~ var { ++n } END { print n }' log.txt`, dimana akan mencari line yang mengandung kata log dan username yang sedang log in.
- Return value berupa hasil perhitungan banyaknya baris yang sesuai dengan pattern yang diminta.

Kemudian masuk ke kondisi apakah _command_ yang diinputkan `dl` atau `att`.

```bash
if [[ "$commnd" == "dl" ]]
then
  download_image
  printf "\n------------------------------"
  printf "\nSUCCESS downloaded $n pictures"
  printf "\n------------------------------\n"
elif [[ "$commnd" == "att" ]]
then
  printf "\n----------------------------"
  printf "\nLOGIN attempts: $(login_try)"
  printf "\n----------------------------\n"
else
  printf "\n----------------------------"
  printf "\nERROR: Invalid command"
  printf "\n----------------------------\n"
fi
```

- Jika `commnd` yang diinputkan adalah `dl`, maka akan dipanggil fungsi `download_image`. Setelah _download_ selesai akan dimunculkan pesan berhasil.
- Jika `commnd` yang diinputkan adalah `att`, maka akan dimunculkan banyaknya percobaan log in sesuai return value dari fungsi `login_try`.
- Jika `commnd` yang diinputkan selain `dl` dan `att`, maka akan muncul error berupa _invalid command_.

## Nomor 3

**minute_log.sh**

Script bash minute*log.sh akan dijalankan setiap menit untuk mencatat data memori dan kapasitas
direktori /home/{user} di dalam file bernama metrics*{YmdHms}.log yang berada di direktori
home/{user}/log. YmdHMS adalah waktu ketika script dijalankan, Y adalah tahun (4 digit),
m adalah bulan, d adalah tanggal, H adalah jam, M adalah menit, dan S adalah detik.
File log yang dihasilkan hanya boleh di read oleh user yang bersangkutan

Script di bawah menginisialisasi nama direktori tempat penyimpanan file log dan nama file log yang akan dihasilkan

```bash
LOG_DIRECTORY="log"

logFileName="metrics_`date +%Y%m%d%H%M%S`.log"
```

Bila direktori untuk menyimpan file log tidak ada, maka akan dibuat terlebih dahulu.
Script di bawah akan mengecek apakah direktori tidak ada dan bila tidak ada, maka akan dibuat
direktori tersebut. ${HOME} adalah variabel yang menyimpan string "/home/{user}"

```bash
if [ ! -d "${HOME}/${LOG_DIRECTORY}" ]
then
	mkdir "${HOME}/${LOG_DIRECTORY}"
fi
```

Isi dari file log adalah data memori, teks /home/{user}/, dan kapasitas dari /home/{user}/.
Untuk mengambil data memori menggunakan command `free -m` yang kemudian dimasukkan ke dalam
array agar stringnya terpecah-pecah oleh " " (spasi). Data memori berada di index 7 hingga 12
dan data swap berada di index 14 hingga 16. Semua data tersebut disimpan ke dalam variabel
logText.

```bash
memoryData=( `free -m` )

logText="${memoryData[7]}"

for((i=8; i<=12; i++))
do
	logText="${logText},${memoryData[$i]}"
done

for((i=14; i<=16; i++))
do
	logText="${logText},${memoryData[$i]}"
done
```

Untuk mengambil data kapasitas dari /home/{user}/ menggunakan command `du -sh ${HOME}` dan teks
keluarannya disimpan ke dalam array untuk memecah hasilnya berdasarkan " " (spasi) karena
data yang dibutuhkan hanya substring pertama (index 0 pada array). Teks /home/{user}/ dan data kapasitas
ditambahkan ke dalam variabel logText.

```bash
userDirectorySize=( `du -sh ${HOME}` )
logText="${logText},${HOME}/,${userDirectorySize[0]}\n"
```

String logText yang telah dibuat kemudian di simpan ke dalam file log, kemudian
permission file log tersebut hanya read only agar tidak terjadi perubahan isi file
dan untuk user lain tidak diperbolehkan membuka file log tersebut. `chmod -wx <file>`
untuk menghilangkan permission write dan execute untuk setiap kelompok user dan
`chmod o-r <file>` untuk menghilangkan permission read untuk kelompok other (user lain)

```bash
printf "${logText}" > "${HOME}/${LOG_DIRECTORY}/${logFileName}"
chmod -wx "${HOME}/${LOG_DIRECTORY}/${logFileName}"
chmod o-r "${HOME}/${LOG_DIRECTORY}/${logFileName}"
```

**aggregate_minutes_to_hourly_log.sh**

Script bash aggregate_minutes_to_hourly_log.sh akan dijalankan setiap jam untuk mendata log file
yang berasal diciptakan oleh minute_log.sh sejam sebelum script aggregate_minutes_to_hourly_log.sh ini dijalankan.
Untuk mendata file-file tersebut, maka harus menentukan dahulu file-file log yang memenuhi syarat dengan melihat
waktu pembuatan file log yang berada di nama file log tersebut, kemudian membaca satu-persatu file tersebut.

Script di bawah menginisialisasi variabel penting yaitu nama direktori
penyimpanan log, kemudian array monthDay berguna untuk mempermudah perhitungan mundur 1 jam
sebelumnya bila menyebabkan mundur bulan. Misalnya bila tanggal script ini dijalankan pada
tanggal 1 April jam 00:00:00, maka file yang perlu dicari adalah file yang dibuat pada tanggal
31 Maret jam 23:00:00 hingga 1 April jam 00:00:00. Karena jumlah hari setiap bulan berbeda,
maka akan lebih cepat melakukan perhitungan mundur tanggal dengan menyimpan jumlah hari setiap bulan.
Kemudian juga menginisialisasi nama file log yang akan dihasilkan

```bash
LOG_DIRECTORY="log"

monthDay=(0 31 28 31 30 31 30 31 31 30 31 30 31)

logFileName="metrics_agg_`date +%Y%m%d%H`.log"
```

Script di bawah untuk mendapatkan waktu ketika script dijalankan yang akan menjadi waktu
batas atas pencarian file yang diciptakan mulai dari sejam sebelum script ini dijalankan
hingga ketika script dijalankan. Untuk data menit dan detik digabungkan menjadi satu
dalam detik untuk mempermudah dilakukannya pengecekan dalam skala menit dan detik
dari suatu file.

```bash
currentTime=($((`date +%-H`)) $((`date +%-M` * 60 + `date +%-S`)))
currentDate=($((`date +%-Y`)) $((`date +%-m`)) $((`date +%-d`)))
```

Seperti minute_log.sh, bila folder direktori penyimpanan tidak ada, maka akan dibaut
terlebih dahulu.

```bash
if [ ! -d "${HOME}/${LOG_DIRECTORY}" ]
then
	mkdir "${HOME}/${LOG_DIRECTORY}"
fi
```

Nama seluruh file pada direktori log diambil menggunakan command `ls` yang nantinya setiap
file akan diperiksa namanya satu persatu

```bash
fileList=`ls "${HOME}/${LOG_DIRECTORY}"`
```

Script di bawah untuk menghitung batas bawah pencarian file. Bila script dijalankan pada pukul 01:00:00
ke atas, untuk mencari waktu dari batas bawah mudah dengan mengurangkan waktu sejam dari waktu
batas atas. Tetapi, bila dijalankan sebelum pukul 01:00:00, maka sejam sebelumnya akan mundur hari.
Ini akan menyebabkan banyak masalah bila terjadi pada tanggal 1 terutama pada tanggal 1 Maret dan 1 Januari.
Bila bukan pada tanggal 1, maka mundur hari hanya perlu mengurangi tanggal sebanyak 1 dan batas bawah jam
pada pukul 23, tetapi bila tanggal 1 maka akan menyebabkan perubahan bulan. Bila tanggal 1 Maret, mundur
bulan akan menjadi bulan Februari dan Februari memiliki sistem kabisat di mana Februari akan memiliki 29
hari bila tahunnya adalah kelipatan 400 atau kelipatan 4 dan bukan kelipatan 100. Kemudian bila tanggal 1
Januari, maka akan menyebabkan pengurangan tahun sebanyak 1. Untuk pengurangan hari, batas bawah jam akan menjadi
pukul 23.

Array monthDay yang telah diinisialisasi di awal digunakan untuk mempermudah pengurangan yang terjadi
pada pukul 0 tanggal 1. Karena bila pengurangan 1 jam terjadi pada waktu tersebut akan menyebabkan batas bawah
menjadi pukul 23 tanggal terakhir dari bulan sebelumnya. Untuk menit dan detik tidak mengalami perubahan karena
mundur 1 jam tidak menyebabkan perubahan menit dan detik.

```bash
if [ ${currentTime[0]} -eq 0 ]
then
	lowerBoundDate=(${currentDate[0]} ${currentDate[1]} ${currentDate[2]})
	lowerBoundTime=(23 ${currentTime[1]})

	if [ ${currentDate[2]} -eq 1 ]
	then
		if [ ${currentDate[1]} -eq 3 ]
		then
			${lowerBoundDate[1]}=2

			if [ $((${currentDate[0]} % 400)) -eq 0 ]
			then
				${lowerBoundDate[2]}=29
			elif [ $((${currentDate[0]} % 4)) -eq 0 ] && [ $((${currentDate[0]} % 100)) -ne 0 ]
			then
				${lowerBoundDate[2]}=29
			else
				${lowerBoundDate[2]}=28
			fi
		elif [ ${currentDate[1]} -eq 1 ]
		then
			${lowerBoundDate[2]}=31
			${lowerBoundDate[1]}=12
			${lowerBoundDate[0]}=$((${currentDate[0]}-1))
		else
			${lowerBoundDate[1]}=$((${currentDate[1]}-1))
			${lowerBoundDate[2]}=${monthDay[${lowerBoundDate[1]}]}
		fi
	else
		${lowerBoundDate[2]}=$((${lowerBoundDate[2]}-1))
	fi
else
	lowerBoundTime=($((${currentTime[0]}-1)) ${currentTime[1]})

	lowerBoundDate=(${currentDate[0]} ${currentDate[1]} ${currentDate[2]})
fi
```

Script di bawah untuk menginisialisasi variabel yang menyimpan nilai-nilai yang didapat
dari file-file yang akan dibaca dan menghitung jumlah file tersebut.

```bash
eligibleFile=0
total=(0 0 0 0 0 0 0 0 0 0)
minimum=(0 0 0 0 0 0 0 0 0 0)
maximum=(0 0 0 0 0 0 0 0 0 0)
```

Script di bawah akan mengecek nama satu-persatu file yang ada di direktori log apakah
merupakan file yang dibuat sejam sebelum script ini dijalankan. Untuk mengeceknya
dengan mengubah keterangan waktu yang terdapat di nama file menjadi integer
dan melakukan pengecekan apakah memenuhi syarat. Selain itu, perlu dilakukan pengecekan nama file
apakah sesuai dengan format nama file log yang dihasilkan oleh minute_log.sh agar tidak terjadi
kesalahan pengubahan nama file menjadi integer. Data tahun, bulan, hari, jam, dan detik didapatkan
dengan mengubah sebagian substring pada nama file. Untuk menit dan detik dijadikan satu dalam
detik agar mempermudah perbandingan dengan waktu batas bawah dan batas atas.

Setelah mendapatkan waktu pembautan file, waktunya akan dicek apakah berada pada range waktu batas bawah
dan batas atas. Karena selang waktu hanyalah sejam, maka pengecekan file hanya perlu mengecek apakah
tahun, bulan, hari, dan jam file tersebut dibuat sama dengan tahun, bulan, hari, dan jam batas atas atau batas bawah.
Bila sama dengan batas atas, maka detiknya akan dibandingkan, bila detiknya kurang atau sama dengan detik batas atas,
maka file memenuhi syarat atau bila sama dengan batas bawah maka detiknya harus lebih besar atau sama
dengan detik batas bawah. Misalnya, bila batas atas adalah 2022-02-23 10:00:00 dan batas bawah adalah
2022-02-23 09:00:00, file yang memenuhi syarat akan diciptakan pada 2022-02-23 dari pukul 09:00:00 hingga 10:00:00
artinya tinggal mengecek menit-detiknya, kalau batas atas harus lebih dari detik batas bawah, jadi hanya akan bisa
untuk yang dibuat pada pukul 09:00:00 hingga 09:59:59, kalau batas atas akan mengecek yang dibuat
pada pukul 10:00:00 hingga 10:00:00. Pengecekan sistem ini hanya dapat terjadi untuk jeda waktu 1 jam karena
bila jeda 2 jam misalnya batas atas pukul 10:30:00 dan batas bawah pukul 08:30:00, pengecekan sistem ini
hanya akan mengecek file yang dibuat pada pukul 08:30:00 hingga 08:59:59 dan 10:00:00 hingga 10:30:00
menyebabkan file yang dibuat pada pukul 09:00:00 hingga 09:59:59 yang seharusnya memenuhi syarat
menjadi tidak memenuhi syarat

Bila file memenuhi syarat, maka isinya akan dibaca menggunakan `awk` dan nilai-nilainya disimpan ke dalam
variabel penyimpanan yang telah dibuat.

```bash
for file in $fileList
do
	if [ ${#file} -eq 26 ] && [ ${file:0:8} == "metrics_" ] && [ ${file:0:12} != "metrics_agg_" ]
	then
		fileYear=$((10#${file:8:4}))
		fileMonth=$((10#${file:12:2}))
		fileDay=$((10#${file:14:2}))
		fileHour=$((10#${file:16:2}))
		fileSeconds=$((10#${file:18:2} * 60 + 10#${file:20:2}))

		if [ $fileYear -eq ${lowerBoundDate[0]} ] && [ $fileMonth -eq ${lowerBoundDate[1]} ] && [ $fileDay -eq ${lowerBoundDate[2]} ] && [ $fileHour -eq ${lowerBoundTime[0]} ]
		then
			if [ $fileSeconds -ge ${lowerBoundTime[1]} ]
			then
				eligibleFile=$(($eligibleFile+1))
				data=( `awk '
					BEGIN {
						FS = ","
					}
					{
						print $1, " ", $2, " ", $3, " ", $4, " ", $5, " ", $6, " ", $7, " ", $8, " ", $9, " ", $11
					}
				' "${HOME}/${LOG_DIRECTORY}/${file}"`)

				data[9]=${data[9]:0:$((${#data[9]}-1))}

				for((i=0; i<10; i++))
				do
					total[$i]=$((${total[$i]}+${data[$i]}))
					if [ $((${minimum[$i]})) -gt $((${data[$i]})) ] || [ $eligibleFile -eq 1 ]
					then
						minimum[$i]=$((${data[$i]}))
					elif [ $((${maximum[$i]})) -lt $((${data[$i]})) ] || [ $eligibleFile -eq 1 ]
					then
						maximum[$i]=$((${data[$i]}))
					fi
				done
			fi
		elif [ $fileYear -eq ${currentDate[0]} ] && [ $fileMonth -eq ${currentDate[1]} ] && [ $fileDay -eq ${currentDate[2]} ] && [ $fileHour -eq ${currentTime[0]} ]
		then
			if [ $fileSeconds -le ${currentTime[1]} ]
			then
				eligibleFile=$(($eligibleFile+1))
				data=( `awk '
					BEGIN {
						FS = ","
					}
					{
						print $1, " ", $2, " ", $3, " ", $4, " ", $5, " ", $6, " ", $7, " ", $8, " ", $9, " ", $11
					}
				' "${HOME}/${LOG_DIRECTORY}/${file}"`)

				data[9]=${data[9]:0:$((${#data[9]}-1))}

				for((i=0; i<10; i++))
				do
					total[$i]=$((${total[$i]}+${data[$i]}))
					if [ $((${minimum[$i]})) -gt $((${data[$i]})) ] || [ $eligibleFile -eq 1 ]
					then
						minimum[$i]=$((${data[$i]}))
					elif [ $((${maximum[$i]})) -lt $((${data[$i]})) ] || [ $eligibleFile -eq 1 ]
					then
						maximum[$i]=$((${data[$i]}))
					fi
				done
			fi
		fi
	fi
done
```

Script di bawah untuk membangun teks log yang akan disimpan di dalam log file beserta dengan
rata-rata data yang telah diciptakan. Karena di dalam contoh soal pada bagian rata-rata terdapat
nilai yang desimal, maka rata-rata yang dihasilkan juga memiliki desimal namun karena pembagian
pada script bash selalu berupa integer, `echo "scale=1; <nilai 1>/<nilai 2>" | bc` yang menyebabkan
setiap nilai meskipun pembagiannya bernilai bulat akan memiliki .0 dibelakangnya
(presisi hingga 1 nilai belakang koma). Berdasarkan contoh soal, nilai belakang koma menggunakan tanda
"." bukan "," sehingga perhitungan tidak menggunakan `awk` karena desimal `awk` menggunakan ",".

```bash
logText="minimum"

for((i=0; i<10; i++))
do
	for((i=0; i<9; i++))
	do
		logText="${logText},${minimum[$i]}"
	done
	logText="${logText},${HOME}/"
	logText="${logText},${minimum[9]}M\n"
done

logText="${logText}maximum"

for((i=0; i<10; i++))
do
	for((i=0; i<9; i++))
	do
		logText="${logText},${maximum[$i]}"
	done
	logText="${logText},${HOME}/"
	logText="${logText},${maximum[9]}M\n"
done

logText="${logText}average"
if [ $eligibleFile -gt 0 ]
then
	for((i=0; i<9; i++))
	do
		division=`echo "scale=1; ${total[$i]}/${eligibleFile}" | bc`
		logText="${logText},${division}"
	done
	logText="${logText},${HOME}/"

	division=`echo "scale=1; ${total[9]}/${eligibleFile}" | bc`
	logText="${logText},${division}M"
else
	logText="${logText},0,0,0,0,0,0,0,0,0,${HOME}/,0M"
fi
```

Kemudian hasil log text disimpan ke dalam file log dan permissionnya
dibatasi hanya menjadi read only untuk semua user kecuali user lain (other)
yang permissionnya dibuat none sehingga sama sekali
tidak bisa membaca file atau mengganti file.

```bash
printf "$logText" > "${HOME}/${LOG_DIRECTORY}/${logFileName}"
chmod -wx "${HOME}/${LOG_DIRECTORY}/${logFileName}"
chmod o-r "${HOME}/${LOG_DIRECTORY}/${logFileName}"
```

**cron**

Untuk menjalankan crontab yang diperlukan adalah

- \* \* \* \* \* bash minute_log.sh
- 0 \* \* \* \* bash aggregate_minutes_to_hourly_log.sh

\* \* \* \* \* akan membuat script bash dijalankan setiap menitnya

0 \* \* \* \* akan membuat script bash dijalankan setiap menit 0 dalam arti lain setiap jam

Kami sudah mencoba membuat script bash untuk langsung membuat crontab ketika program dijalankan yaitu dengan
crontab menjalankan semua script yang terdapat di dalam file bash (bukan menjalankan bash, tetapi langsung
kumpulan script yang di dalam bash dituliskan di crontab) namun sayangnya tidak dapat dijalankan
karena command `logFileName="metrics_agg_\`date +%Y%m%d%H\`.log"` yang entah mengapa tidak dapat dijalankan
namun ketika scriptnya di-copy dan dijalankan langsung pada terminal dapat berjalan dengan baik.

**Dokumentasi Pengerjaan dan Rintangan**

Berikut adalah beberapa screenshoot dokumentasi pengerjaan dan rintangan

---

Rintangan yang dihadapi adalah mencari direktori /home/{user}/ yang ternyata nilainya disimpan pada variabel
$HOME. Kemudian melakukan partisi string data memori yang berasal dari `free -m` yang dapat dilakukan dengan
memasukkannya ke dalam array sehingga dipecah-pecah oleh " " (spasi). Kemudian membuat nama file log
berdasarkan waktu menggunakan `date` karena syntaxnya cukup banyak dan membingunkan. Kemudian melakukan
pengecekan file yang memenuhi syarat waktu yang membingungkan karena mundur sejam sebelum script
aggregate_minutes_to_hourly_log.sh bisa berbeda hari, bulan, hingga tahun dan adanya tahun kabisat.
Kemudian membatasi permission file yang dibuat, kami mengasumsikan file hanya dapat dibaca oleh user yang
bersangkutan dan tidak ada user yang dapat mengubah isinya (termasuk pembuatnya). Rintangan terakhir adalah
crontab (sudah dijelaskan di bagian cron).
