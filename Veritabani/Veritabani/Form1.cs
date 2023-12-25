using Npgsql;
using System.Data;
using System.Windows.Forms;

namespace Veritabani
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }
        NpgsqlConnection baglanti=new NpgsqlConnection("server=localHost; port=5432; Database=OyunVeritabani2; user ID=postgres; password=12345");
        private void button1_Click(object sender, EventArgs e)
        {
            string sorgu = "SELECT kisi.*, il.ilAdi FROM kisi INNER JOIN il ON il.ilplaka= kisi.ilno";
            NpgsqlDataAdapter da = new NpgsqlDataAdapter(sorgu, baglanti);
            DataSet ds = new DataSet();
            da.Fill(ds);
            dataGridView1.DataSource = ds.Tables[0];
            baglanti.Close();
        }

        private void DeleteUserById(int userId)
        {
            try
            {
                
                
                    baglanti.Open();

                    string deleteQuery = "DELETE FROM Kisi WHERE KisiNo = @UserId";

                    using (NpgsqlCommand command = new NpgsqlCommand(deleteQuery, baglanti))
                    {
                        command.Parameters.AddWithValue("@UserId", userId);

                        int rowsAffected = command.ExecuteNonQuery();

                        if (rowsAffected > 0)
                        {
                            MessageBox.Show("Kullanýcý baþarýyla silindi.");
                        }
                        else
                        {
                            MessageBox.Show("Kullanýcý bulunamadý.");
                        }
                    }
                
            }
            catch (Exception ex)
            {
                MessageBox.Show("Hata: " + ex.Message);
            }
        }









        private void button5_Click(object sender, EventArgs e)
        {
            if (int.TryParse(txtIDForSil.Text, out int userId))
            {
                DeleteUserById(userId);
            }
            else
            {
                MessageBox.Show("Geçerli bir KisiNo giriniz.");
            }
            baglanti.Close();

            try
            {
                // Baðlantýyý aç
                baglanti.Open();

                // Veritabanýndan kiþilerin ID'lerini çek
                string sorgu = "select kisino from kisi";
                NpgsqlCommand komut2 = new NpgsqlCommand(sorgu, baglanti);

                using (NpgsqlDataAdapter da = new NpgsqlDataAdapter(komut2))
                {
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    // ComboBox'ý doldur
                    comboBoxKullanicilar1.DisplayMember = "kisino";
                    comboBoxKullanicilar1.ValueMember = "kisino";
                    comboBoxKullanicilar1.DataSource = dt;
              
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Hata: " + ex.Message);
            }
            finally
            {
                // Baðlantýyý kapat
                baglanti.Close();
            }


            try
            {
                // Baðlantýyý aç
                baglanti.Open();

                // Veritabanýndan kiþilerin ID'lerini çek
                string sorgu = "select kisino from kisi";
                NpgsqlCommand komut2 = new NpgsqlCommand(sorgu, baglanti);

                using (NpgsqlDataAdapter da = new NpgsqlDataAdapter(komut2))
                {
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    // ComboBox'ý doldur

                    comboBoxKullanicilar2.DisplayMember = "kisino";
                    comboBoxKullanicilar2.ValueMember = "kisino";
                    comboBoxKullanicilar2.DataSource = dt;
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Hata: " + ex.Message);
            }
            finally
            {
                // Baðlantýyý kapat
                baglanti.Close();
            }

        }

        private void button2_Click(object sender, EventArgs e)
        {
            baglanti.Open();
            //listeleButton
            string isim = ListeleIsýmTextBox.Text;
            string sorgu = "SELECT Kisi.KisiNo, Kisi.Adi, Kisi.Soyadi, Kisi.AktifMi, Kisi.IlNo, il.iladi, Yapimci.KisiNo AS YapimciKisiNo, Oyuncu.KisiNo AS OyuncuKisiNo, Oyuncu.bakiye AS oyuncuBakiye, Calisan.kisino AS CalisanKisiNo, Calisan.yetkino, Calisan.DepartmanNo FROM Kisi LEFT JOIN Yapimci ON Kisi.KisiNo = Yapimci.KisiNo LEFT JOIN Oyuncu ON Kisi.KisiNo = Oyuncu.KisiNo LEFT JOIN Calisan ON Kisi.KisiNo = Calisan.KisiNo LEFT JOIN il ON il.ilplaka = Kisi.IlNo WHERE Kisi.Adi = @isim;";


            using (NpgsqlCommand command = new NpgsqlCommand(sorgu, baglanti))
            {
                command.Parameters.AddWithValue("@isim", isim);

                using (NpgsqlDataAdapter da = new NpgsqlDataAdapter(command))
                {
                    DataSet ds = new DataSet();
                    da.Fill(ds);
                    dataGridView1.DataSource = ds.Tables[0];
                }
            }
            baglanti.Close();
        }

        private void textBox1_TextChanged(object sender, EventArgs e)
        {

        }
        //Text Box Ara
        private void button6_Click(object sender, EventArgs e)
        {

            baglanti.Open();

            // TextBox'taki metni bir tamsayýya dönüþtürme
            if (int.TryParse(TextBoxAra.Text, out int id))
            {
                string sorgu = "SELECT Kisi.KisiNo, Kisi.Adi, Kisi.Soyadi, Kisi.AktifMi, Kisi.IlNo, il.ilAdi, Yapimci.KisiNo AS YapimciKisiNo, Oyuncu.KisiNo AS OyuncuKisiNo, Oyuncu.bakiye AS oyuncuBakiye, Calisan.kisino AS CalisanKisiNo, Calisan.yetkino, Calisan.DepartmanNo FROM Kisi LEFT JOIN Yapimci ON Kisi.KisiNo = Yapimci.KisiNo LEFT JOIN Oyuncu ON Kisi.KisiNo = Oyuncu.KisiNo LEFT JOIN Calisan ON Kisi.KisiNo = Calisan.KisiNo LEFT JOIN il ON il.ilplaka = Kisi.IlNo WHERE Kisi.KisiNo = @id;";

                using (NpgsqlCommand komut = new NpgsqlCommand(sorgu, baglanti))
                {
                    // Parametre ekleme
                    komut.Parameters.AddWithValue("@id", id);

                    using (NpgsqlDataAdapter da = new NpgsqlDataAdapter(komut))
                    {
                        // DataSet ve DataTable oluþtur
                        DataSet ds = new DataSet();
                        DataTable dt = new DataTable();

                        // Verileri çek ve DataSet'e ekle
                        da.Fill(ds, "KisiBilgileri");

                        // DataTable'a DataSet'ten eriþim
                        dt = ds.Tables["KisiBilgileri"];

                        // DataGridView'e DataTable'ý baðla
                        dataGridView1.DataSource = dt;
                    }
                }
            }
            else
            {
                // Hata durumu: TextBox'taki metni bir tamsayýya dönüþtürme baþarýsýz oldu
                MessageBox.Show("Geçersiz ID formatý.");
            }

            baglanti.Close();
        }

        private void GuncelleButton_Click(object sender, EventArgs e)
        {
            baglanti.Open();
            using (NpgsqlCommand komut = new NpgsqlCommand("UPDATE Kisi SET Adi = @YeniIsim WHERE KisiNo = @KisiNo; SELECT * FROM Kisi ORDER BY KisiNo ASC;", baglanti))
            {
                komut.Parameters.AddWithValue("@YeniIsim", textBoxYeniIsim.Text);
                komut.Parameters.AddWithValue("@KisiNo", Convert.ToInt32(textBoxGunceleID.Text));

                // Sorguyu çalýþtýrma
                komut.ExecuteNonQuery();
            }
            baglanti.Close();
        }

        private void label4_Click(object sender, EventArgs e)
        {

        }

        private void button3_Click(object sender, EventArgs e)
        {
            //oyuncuEkleButton
            baglanti.Open();

            using (NpgsqlCommand komut = new NpgsqlCommand("INSERT INTO Kisi (IlNo, KisiNo, Adi, Soyadi, AktifMi) " +
                                                           "VALUES (@IlNo, @KisiNo, @Adi, @Soyadi, @AktifMi); " +
                                                           "SELECT * FROM Kisi ORDER BY KisiNo ASC;", baglanti))
            {
                komut.Parameters.AddWithValue("@IlNo", Convert.ToInt32(numericUpDownIlPlaka.Value));
                komut.Parameters.AddWithValue("@KisiNo", Convert.ToInt32(textBoxEkleKisiID.Text));
                komut.Parameters.AddWithValue("@Adi", textBoxEkleKisiAdi.Text);
                komut.Parameters.AddWithValue("@Soyadi", textBoxEkleKisiSoyAdi.Text);
                komut.Parameters.AddWithValue("@AktifMi", checkBoxKisiAktifMi.Checked);

                // Sorguyu çalýþtýrma
                komut.ExecuteNonQuery();
            }

            baglanti.Close();

            baglanti.Open();

            using (NpgsqlCommand komut = new NpgsqlCommand("INSERT INTO Oyuncu (KisiNo, Bakiye) " +
                                                           "VALUES (@KisiNo, @Bakiye); " +
                                                           "SELECT * FROM Oyuncu ORDER BY KisiNo ASC;", baglanti))
            {
                komut.Parameters.AddWithValue("@KisiNo", Convert.ToInt32(textBoxEkleKisiID.Text));
                komut.Parameters.AddWithValue("@Bakiye", Convert.ToInt32(textBoxBakiyeOyuncu.Text));

                // Sorguyu çalýþtýrma
                komut.ExecuteNonQuery();
            }

            baglanti.Close();
            try
            {
                baglanti.Open();
                string sorgu = "SELECT KisiNo FROM Oyuncu"; // Oyuncu tablosundan KisiNo'larý seç
                NpgsqlCommand komut = new NpgsqlCommand(sorgu, baglanti);

                using (NpgsqlDataAdapter da = new NpgsqlDataAdapter(komut))
                {
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    // ComboBox'ý doldur
                    comboBoxOyuncuID.DisplayMember = "kisino";
                    comboBoxOyuncuID.ValueMember = "kisino";
                    comboBoxOyuncuID.DataSource = dt;
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Hata: " + ex.Message);
            }
            finally
            {
                baglanti.Close();
            }
            try
            {
                // Baðlantýyý aç
                baglanti.Open();

                // Veritabanýndan kiþilerin ID'lerini çek
                string sorgu = "select kisino from kisi";
                NpgsqlCommand komut2 = new NpgsqlCommand(sorgu, baglanti);

                using (NpgsqlDataAdapter da = new NpgsqlDataAdapter(komut2))
                {
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    // ComboBox'ý doldur
                    comboBoxKullanicilar1.DisplayMember = "kisino";
                    comboBoxKullanicilar1.ValueMember = "kisino";
                    comboBoxKullanicilar1.DataSource = dt;
                  
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Hata: " + ex.Message);
            }
            finally
            {
                // Baðlantýyý kapat
                baglanti.Close();
            }


            try
            {
                // Baðlantýyý aç
                baglanti.Open();

                // Veritabanýndan kiþilerin ID'lerini çek
                string sorgu = "select kisino from kisi";
                NpgsqlCommand komut2 = new NpgsqlCommand(sorgu, baglanti);

                using (NpgsqlDataAdapter da = new NpgsqlDataAdapter(komut2))
                {
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    // ComboBox'ý doldur

                    comboBoxKullanicilar2.DisplayMember = "kisino";
                    comboBoxKullanicilar2.ValueMember = "kisino";
                    comboBoxKullanicilar2.DataSource = dt;
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Hata: " + ex.Message);
            }
            finally
            {
                // Baðlantýyý kapat
                baglanti.Close();
            }

        }

        private void label10_Click(object sender, EventArgs e)
        {

        }

        private void numericUpDown2_ValueChanged(object sender, EventArgs e)
        {

        }

        private void label8_Click(object sender, EventArgs e)
        {

        }

        private void button4_Click(object sender, EventArgs e)
        {
            //Calisan Ekle button
            baglanti.Open();

            using (NpgsqlCommand komut = new NpgsqlCommand("INSERT INTO Kisi (IlNo, KisiNo, Adi, Soyadi, AktifMi) " +
                                                           "VALUES (@IlNo, @KisiNo, @Adi, @Soyadi, @AktifMi); " +
                                                           "SELECT * FROM Kisi ORDER BY KisiNo ASC;", baglanti))
            {
                komut.Parameters.AddWithValue("@IlNo", Convert.ToInt32(numericUpDownIlPlaka.Value));
                komut.Parameters.AddWithValue("@KisiNo", Convert.ToInt32(textBoxEkleKisiID.Text));
                komut.Parameters.AddWithValue("@Adi", textBoxEkleKisiAdi.Text);
                komut.Parameters.AddWithValue("@Soyadi", textBoxEkleKisiSoyAdi.Text);
                komut.Parameters.AddWithValue("@AktifMi", checkBoxKisiAktifMi.Checked);

                // Sorguyu çalýþtýrma
                komut.ExecuteNonQuery();
            }

            baglanti.Close();


            baglanti.Open();

            using (NpgsqlCommand komut = new NpgsqlCommand("INSERT INTO calisan (KisiNo, yetkino, departmanno) " +
                                                           "VALUES (@KisiNo, @yetkino, @departmanno); " +
                                                           "SELECT * FROM calisan ORDER BY KisiNo ASC;", baglanti))
            {
                komut.Parameters.AddWithValue("@KisiNo", Convert.ToInt32(textBoxEkleKisiID.Text));
                komut.Parameters.AddWithValue("@yetkino", numericUpDownYetkNoCalisan.Value);
                komut.Parameters.AddWithValue("@departmanno", numericUpDownDepartmanNoCalisan.Value);

                // Sorguyu çalýþtýrma
                komut.ExecuteNonQuery();
            }

            baglanti.Close();

            try
            {
                baglanti.Open();
                string sorgu = "SELECT KisiNo FROM Calisan"; // Calisan tablosundan KisiNo'larý seç
                NpgsqlCommand komut = new NpgsqlCommand(sorgu, baglanti);

                using (NpgsqlDataAdapter da = new NpgsqlDataAdapter(komut))
                {
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    // ComboBox'ý doldur
                    comboBoxCalisanID.DisplayMember = "KisiNo";
                    comboBoxCalisanID.ValueMember = "KisiNo";
                    comboBoxCalisanID.DataSource = dt;
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Hata: " + ex.Message);
            }
            finally
            {
                baglanti.Close();
            }

            try
            {
                // Baðlantýyý aç
                baglanti.Open();

                // Veritabanýndan kiþilerin ID'lerini çek
                string sorgu = "select kisino from kisi";
                NpgsqlCommand komut2 = new NpgsqlCommand(sorgu, baglanti);

                using (NpgsqlDataAdapter da = new NpgsqlDataAdapter(komut2))
                {
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    // ComboBox'ý doldur
                    comboBoxKullanicilar1.DisplayMember = "kisino";
                    comboBoxKullanicilar1.ValueMember = "kisino";
                    comboBoxKullanicilar1.DataSource = dt;
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Hata: " + ex.Message);
            }
            finally
            {
                // Baðlantýyý kapat
                baglanti.Close();
            }


            try
            {
                // Baðlantýyý aç
                baglanti.Open();

                // Veritabanýndan kiþilerin ID'lerini çek
                string sorgu = "select kisino from kisi";
                NpgsqlCommand komut2 = new NpgsqlCommand(sorgu, baglanti);

                using (NpgsqlDataAdapter da = new NpgsqlDataAdapter(komut2))
                {
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    // ComboBox'ý doldur

                    comboBoxKullanicilar2.DisplayMember = "kisino";
                    comboBoxKullanicilar2.ValueMember = "kisino";
                    comboBoxKullanicilar2.DataSource = dt;
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Hata: " + ex.Message);
            }
            finally
            {
                // Baðlantýyý kapat
                baglanti.Close();
            }

        }

        private void yapimciEkleClick(object sender, EventArgs e)
        {
            baglanti.Open();

            using (NpgsqlCommand komut = new NpgsqlCommand("INSERT INTO Kisi (IlNo, KisiNo, Adi, Soyadi, AktifMi) " +
                                                           "VALUES (@IlNo, @KisiNo, @Adi, @Soyadi, @AktifMi); " +
                                                           "SELECT * FROM Kisi ORDER BY KisiNo ASC;", baglanti))
            {
                komut.Parameters.AddWithValue("@IlNo", Convert.ToInt32(numericUpDownIlPlaka.Value));
                komut.Parameters.AddWithValue("@KisiNo", Convert.ToInt32(textBoxEkleKisiID.Text));
                komut.Parameters.AddWithValue("@Adi", textBoxEkleKisiAdi.Text);
                komut.Parameters.AddWithValue("@Soyadi", textBoxEkleKisiSoyAdi.Text);
                komut.Parameters.AddWithValue("@AktifMi", checkBoxKisiAktifMi.Checked);

                // Sorguyu çalýþtýrma
                komut.ExecuteNonQuery();
            }

            baglanti.Close();

            baglanti.Open();

            using (NpgsqlCommand komut = new NpgsqlCommand("INSERT INTO yapimci (KisiNo) " +
                                                           "VALUES (@KisiNo);" , baglanti))
            {
                komut.Parameters.AddWithValue("@KisiNo", Convert.ToInt32(textBoxEkleKisiID.Text));

                // Sorguyu çalýþtýrma
                komut.ExecuteNonQuery();
            }

            baglanti.Close();



            try
            {
                baglanti.Open();
                string sorgu = "SELECT KisiNo FROM Yapimci"; // Yapimci tablosundan KisiNo'larý seç
                NpgsqlCommand komut = new NpgsqlCommand(sorgu, baglanti);

                using (NpgsqlDataAdapter da = new NpgsqlDataAdapter(komut))
                {
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    // ComboBox'ý doldur
                    comboBoxYapimciID.DisplayMember = "KisiNo";
                    comboBoxYapimciID.ValueMember = "KisiNo";
                    comboBoxYapimciID.DataSource = dt;
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Hata: " + ex.Message);
            }
            finally
            {
                baglanti.Close();
            }

            try
            {
                // Baðlantýyý aç
                baglanti.Open();

                // Veritabanýndan kiþilerin ID'lerini çek
                string sorgu = "select kisino from kisi";
                NpgsqlCommand komut2 = new NpgsqlCommand(sorgu, baglanti);

                using (NpgsqlDataAdapter da = new NpgsqlDataAdapter(komut2))
                {
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    // ComboBox'ý doldur
                    comboBoxKullanicilar1.DisplayMember = "kisino";
                    comboBoxKullanicilar1.ValueMember = "kisino";
                    comboBoxKullanicilar1.DataSource = dt;
               
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Hata: " + ex.Message);
            }
            finally
            {
                // Baðlantýyý kapat
                baglanti.Close();
            }

            try
            {
                // Baðlantýyý aç
                baglanti.Open();

                // Veritabanýndan kiþilerin ID'lerini çek
                string sorgu = "select kisino from kisi";
                NpgsqlCommand komut2 = new NpgsqlCommand(sorgu, baglanti);

                using (NpgsqlDataAdapter da = new NpgsqlDataAdapter(komut2))
                {
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    // ComboBox'ý doldur

                    comboBoxKullanicilar2.DisplayMember = "kisino";
                    comboBoxKullanicilar2.ValueMember = "kisino";
                    comboBoxKullanicilar2.DataSource = dt;
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Hata: " + ex.Message);
            }
            finally
            {
                // Baðlantýyý kapat
                baglanti.Close();
            }

        }

        private void comboBox1_SelectedIndexChanged(object sender, EventArgs e)
        {

        }

        private void OyuncuSilButton_Click(object sender, EventArgs e)
        {



            baglanti.Open();

            using (NpgsqlCommand komut2 = new NpgsqlCommand("DELETE FROM kisi WHERE kisino = @kisino;", baglanti))
            {
                komut2.Parameters.AddWithValue("@kisino", (int)comboBoxOyuncuID.SelectedValue);

                // Sorguyu çalýþtýrma
                komut2.ExecuteNonQuery();
            }
            baglanti.Close();

            
            baglanti.Open();
            try
            {
               
                string sorgu = "SELECT KisiNo FROM Oyuncu"; // Oyuncu tablosundan KisiNo'larý seç
                NpgsqlCommand komut = new NpgsqlCommand(sorgu, baglanti);

                using (NpgsqlDataAdapter da = new NpgsqlDataAdapter(komut))
                {
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    // ComboBox'ý doldur
                    comboBoxOyuncuID.DisplayMember = "kisino";
                    comboBoxOyuncuID.ValueMember = "kisino";
                    comboBoxOyuncuID.DataSource = dt;
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Hata: " + ex.Message);
            }
            finally
            {
                baglanti.Close();
            }

            try
            {
                // Baðlantýyý aç
                baglanti.Open();

                // Veritabanýndan kiþilerin ID'lerini çek
                string sorgu = "select kisino from kisi";
                NpgsqlCommand komut2 = new NpgsqlCommand(sorgu, baglanti);

                using (NpgsqlDataAdapter da = new NpgsqlDataAdapter(komut2))
                {
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    // ComboBox'ý doldur
                    comboBoxKullanicilar1.DisplayMember = "kisino";
                    comboBoxKullanicilar1.ValueMember = "kisino";
                    comboBoxKullanicilar1.DataSource = dt;
              
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Hata: " + ex.Message);
            }
            finally
            {
                // Baðlantýyý kapat
                baglanti.Close();
            }

            try
            {
                // Baðlantýyý aç
                baglanti.Open();

                // Veritabanýndan kiþilerin ID'lerini çek
                string sorgu = "select kisino from kisi";
                NpgsqlCommand komut2 = new NpgsqlCommand(sorgu, baglanti);

                using (NpgsqlDataAdapter da = new NpgsqlDataAdapter(komut2))
                {
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    // ComboBox'ý doldur

                    comboBoxKullanicilar2.DisplayMember = "kisino";
                    comboBoxKullanicilar2.ValueMember = "kisino";
                    comboBoxKullanicilar2.DataSource = dt;
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Hata: " + ex.Message);
            }
            finally
            {
                // Baðlantýyý kapat
                baglanti.Close();
            }



        }

        private void Form1_Load(object sender, EventArgs e)
        {
            try
            {
                // Baðlantýyý aç
                baglanti.Open();

                // Veritabanýndan istatistik ID'lerini çek
                using (NpgsqlCommand komut = new NpgsqlCommand("SELECT IstatistikID FROM IstatistikREF", baglanti))
                {
                    // Okuma iþlemini baþlat
                    using (NpgsqlDataReader reader = komut.ExecuteReader())
                    {
                        // ComboBox'ý temizle
                        comboBoxIstatistik.Items.Clear();

                        // Verileri ComboBox'a ekle
                        while (reader.Read())
                        {
                            int istatistikID = reader.GetInt32(0);

                            // ComboBox'a yeni öðe ekle
                            comboBoxIstatistik.Items.Add(istatistikID);
                        }

                        // ComboBox'ta gösterilecek metni ve deðeri belirle
                        comboBoxIstatistik.DisplayMember = "IstatistikID";
                        comboBoxIstatistik.ValueMember = "IstatistikID";

                        // Ýlk öðeyi seç
                        if (comboBoxIstatistik.Items.Count > 0)
                        {
                            comboBoxIstatistik.SelectedIndex = 0;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Hata: " + ex.Message);
            }
            finally
            {
                // Baðlantýyý kapat
                baglanti.Close();
            }
            try
            {
                string sorgu = "SELECT ArkadaslikID FROM ArkadasKayit";
                NpgsqlCommand komut = new NpgsqlCommand(sorgu, baglanti);
                using (NpgsqlDataAdapter da = new NpgsqlDataAdapter(komut))
                {
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    // ComboBox'ý doldur
                    comboBoxArkadaslikIstekleri.DisplayMember = "arkadaslikid";
                    comboBoxArkadaslikIstekleri.ValueMember = "arkadaslikid";
                    comboBoxArkadaslikIstekleri.DataSource = dt;
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Hata: " + ex.Message);
            }
            finally
            {
                // Baðlantýyý kapat
                baglanti.Close();
            }



            try
            {
                // Baðlantýyý aç
                baglanti.Open();

                // Veritabanýndan kiþilerin ID'lerini çek
                string sorgu = "select kisino from kisi";
                NpgsqlCommand komut2 = new NpgsqlCommand(sorgu, baglanti);

                using (NpgsqlDataAdapter da = new NpgsqlDataAdapter(komut2))
                {
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    // ComboBox'ý doldur
                    comboBoxKullanicilar1.DisplayMember = "kisino";
                    comboBoxKullanicilar1.ValueMember = "kisino";
                    comboBoxKullanicilar1.DataSource = dt;

                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Hata: " + ex.Message);
            }
            finally
            {
                // Baðlantýyý kapat
                baglanti.Close();
            }

            try
            {
                // Baðlantýyý aç
                baglanti.Open();

                // Veritabanýndan kiþilerin ID'lerini çek
                string sorgu = "select kisino from kisi";
                NpgsqlCommand komut2 = new NpgsqlCommand(sorgu, baglanti);

                using (NpgsqlDataAdapter da = new NpgsqlDataAdapter(komut2))
                {
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    // ComboBox'ý doldur
                    
                    comboBoxKullanicilar2.DisplayMember = "kisino";
                    comboBoxKullanicilar2.ValueMember = "kisino";
                    comboBoxKullanicilar2.DataSource = dt;
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Hata: " + ex.Message);
            }
            finally
            {
                // Baðlantýyý kapat
                baglanti.Close();
            }



            //***
            try
            {
                baglanti.Open();
                string sorgu = "SELECT KisiNo FROM Oyuncu"; // Oyuncu tablosundan KisiNo'larý seç
                NpgsqlCommand komut = new NpgsqlCommand(sorgu, baglanti);

                using (NpgsqlDataAdapter da = new NpgsqlDataAdapter(komut))
                {
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    // ComboBox'ý doldur
                    comboBoxOyuncuID.DisplayMember = "kisino";
                    comboBoxOyuncuID.ValueMember = "kisino";
                    comboBoxOyuncuID.DataSource = dt;
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Hata: " + ex.Message);
            }
            finally
            {
                baglanti.Close();
            }


            try
            {
                baglanti.Open();
                string sorgu = "SELECT KisiNo FROM Calisan"; // Calisan tablosundan KisiNo'larý seç
                NpgsqlCommand komut = new NpgsqlCommand(sorgu, baglanti);

                using (NpgsqlDataAdapter da = new NpgsqlDataAdapter(komut))
                {
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    // ComboBox'ý doldur
                    comboBoxCalisanID.DisplayMember = "KisiNo";
                    comboBoxCalisanID.ValueMember = "KisiNo";
                    comboBoxCalisanID.DataSource = dt;
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Hata: " + ex.Message);
            }
            finally
            {
                baglanti.Close();
            }


            try
            {
                baglanti.Open();
                string sorgu = "SELECT KisiNo FROM Yapimci"; // Yapimci tablosundan KisiNo'larý seç
                NpgsqlCommand komut = new NpgsqlCommand(sorgu, baglanti);

                using (NpgsqlDataAdapter da = new NpgsqlDataAdapter(komut))
                {
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    // ComboBox'ý doldur
                    comboBoxYapimciID.DisplayMember = "KisiNo";
                    comboBoxYapimciID.ValueMember = "KisiNo";
                    comboBoxYapimciID.DataSource = dt;
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Hata: " + ex.Message);
            }
            finally
            {
                baglanti.Close();
            }
        }

        private void CalisanSilButton_Click(object sender, EventArgs e)
        {

            baglanti.Open();

            using (NpgsqlCommand komut2 = new NpgsqlCommand("DELETE FROM kisi WHERE kisino = @kisino;", baglanti))
            {
                komut2.Parameters.AddWithValue("@kisino", comboBoxCalisanID.SelectedValue);

                // Sorguyu çalýþtýrma
                komut2.ExecuteNonQuery();
            }
            baglanti.Close();

            try
            {
                baglanti.Open();
                string sorgu = "SELECT KisiNo FROM Calisan"; // Calisan tablosundan KisiNo'larý seç
                NpgsqlCommand komut = new NpgsqlCommand(sorgu, baglanti);

                using (NpgsqlDataAdapter da = new NpgsqlDataAdapter(komut))
                {
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    // ComboBox'ý doldur
                    comboBoxCalisanID.DisplayMember = "KisiNo";
                    comboBoxCalisanID.ValueMember = "KisiNo";
                    comboBoxCalisanID.DataSource = dt;
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Hata: " + ex.Message);
            }
            finally
            {
                baglanti.Close();
            }

            try
            {
                // Baðlantýyý aç
                baglanti.Open();

                // Veritabanýndan kiþilerin ID'lerini çek
                string sorgu = "select kisino from kisi";
                NpgsqlCommand komut2 = new NpgsqlCommand(sorgu, baglanti);

                using (NpgsqlDataAdapter da = new NpgsqlDataAdapter(komut2))
                {
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    // ComboBox'ý doldur
                    comboBoxKullanicilar1.DisplayMember = "kisino";
                    comboBoxKullanicilar1.ValueMember = "kisino";
                    comboBoxKullanicilar1.DataSource = dt;
                 
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Hata: " + ex.Message);
            }
            finally
            {
                // Baðlantýyý kapat
                baglanti.Close();
            }


            try
            {
                // Baðlantýyý aç
                baglanti.Open();

                // Veritabanýndan kiþilerin ID'lerini çek
                string sorgu = "select kisino from kisi";
                NpgsqlCommand komut2 = new NpgsqlCommand(sorgu, baglanti);

                using (NpgsqlDataAdapter da = new NpgsqlDataAdapter(komut2))
                {
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    // ComboBox'ý doldur

                    comboBoxKullanicilar2.DisplayMember = "kisino";
                    comboBoxKullanicilar2.ValueMember = "kisino";
                    comboBoxKullanicilar2.DataSource = dt;
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Hata: " + ex.Message);
            }
            finally
            {
                // Baðlantýyý kapat
                baglanti.Close();
            }
        }

        private void YapimciSilButton_Click(object sender, EventArgs e)
        {

            baglanti.Open();

            using (NpgsqlCommand komut2 = new NpgsqlCommand("DELETE FROM kisi WHERE kisino = @kisino;", baglanti))
            {
                komut2.Parameters.AddWithValue("@kisino", comboBoxYapimciID.SelectedValue);

                // Sorguyu çalýþtýrma
                komut2.ExecuteNonQuery();
            }
            baglanti.Close();
            try
            {
                baglanti.Open();
                string sorgu = "SELECT KisiNo FROM Yapimci"; // Yapimci tablosundan KisiNo'larý seç
                NpgsqlCommand komut = new NpgsqlCommand(sorgu, baglanti);

                using (NpgsqlDataAdapter da = new NpgsqlDataAdapter(komut))
                {
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    // ComboBox'ý doldur
                    comboBoxYapimciID.DisplayMember = "KisiNo";
                    comboBoxYapimciID.ValueMember = "KisiNo";
                    comboBoxYapimciID.DataSource = dt;
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Hata: " + ex.Message);
            }
            finally
            {
                baglanti.Close();
            }

            try
            {
                // Baðlantýyý aç
                baglanti.Open();

                // Veritabanýndan kiþilerin ID'lerini çek
                string sorgu = "select kisino from kisi";
                NpgsqlCommand komut2 = new NpgsqlCommand(sorgu, baglanti);

                using (NpgsqlDataAdapter da = new NpgsqlDataAdapter(komut2))
                {
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    // ComboBox'ý doldur
                    comboBoxKullanicilar1.DisplayMember = "kisino";
                    comboBoxKullanicilar1.ValueMember = "kisino";
                    comboBoxKullanicilar1.DataSource = dt;
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Hata: " + ex.Message);
            }
            finally
            {
                // Baðlantýyý kapat
                baglanti.Close();
            }



            try
            {
                // Baðlantýyý aç
                baglanti.Open();

                // Veritabanýndan kiþilerin ID'lerini çek
                string sorgu = "select kisino from kisi";
                NpgsqlCommand komut2 = new NpgsqlCommand(sorgu, baglanti);

                using (NpgsqlDataAdapter da = new NpgsqlDataAdapter(komut2))
                {
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    // ComboBox'ý doldur

                    comboBoxKullanicilar2.DisplayMember = "kisino";
                    comboBoxKullanicilar2.ValueMember = "kisino";
                    comboBoxKullanicilar2.DataSource = dt;
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Hata: " + ex.Message);
            }
            finally
            {
                // Baðlantýyý kapat
                baglanti.Close();
            }

        }

        private void LogButton_Click(object sender, EventArgs e)
        {
            string sorgu = "SELECT log.*, il.ilAdi FROM log INNER JOIN il ON il.ilplaka = log.ilno";
            NpgsqlDataAdapter da = new NpgsqlDataAdapter(sorgu, baglanti);
            DataSet ds = new DataSet();
            da.Fill(ds);
            dataGridView1.DataSource = ds.Tables[0];
            baglanti.Close();
        }

        private void BasarilariGosterButton_Click(object sender, EventArgs e)
        {
            try{
                baglanti.Open();

                string sorgu = "SELECT Basarilar.*, Kisi.Adi AS OyuncuAdi, Kisi.Soyadi AS OyuncuSoyadi, Kisi.AktifMi AS OyuncuAktifMi, Kisi.IlNo AS OyuncuIlNo, BasariREF.BasariAdi " +
                               "FROM Basarilar " +
                               "INNER JOIN Oyuncu ON Basarilar.KisiNo = Oyuncu.KisiNo " +
                               "INNER JOIN Kisi ON Oyuncu.KisiNo = Kisi.KisiNo " +
                               "INNER JOIN BasariREF ON Basarilar.BasariID = BasariREF.BasariID";

                NpgsqlDataAdapter da = new NpgsqlDataAdapter(sorgu, baglanti);
                DataSet ds = new DataSet();
                da.Fill(ds);

                dataGridView1.DataSource = ds.Tables[0];
            }
            catch (Exception ex)
            {
                MessageBox.Show("Hata: " + ex.Message);
            }
            finally
            {
                baglanti.Close();
            }
        }

        private void OyunlarSahipButton_Click(object sender, EventArgs e)
        {
            try
            {
                baglanti.Open();

                string sorgu = "SELECT SahipOyunlar.*, Oyuncu.KisiNo AS OyuncuKisiNo, Oyuncu.Bakiye, OyunlarReferans.OyunID AS OyunlarReferansID, OyunlarReferans.OyunAdi, OyunlarReferans.CikisTarihi " +
                               "FROM SahipOyunlar " +
                               "INNER JOIN Oyuncu ON SahipOyunlar.KisiNo = Oyuncu.KisiNo " +
                               "INNER JOIN OyunlarReferans ON SahipOyunlar.OyunID = OyunlarReferans.OyunID";

                NpgsqlDataAdapter da = new NpgsqlDataAdapter(sorgu, baglanti);
                DataSet ds = new DataSet();
                da.Fill(ds);

                dataGridView1.DataSource = ds.Tables[0];
            }
            catch (Exception ex)
            {
                MessageBox.Show("Hata: " + ex.Message);
            }
            finally
            {
                baglanti.Close();
            }
        }

        private void OyuncuIstatýstýkGosterButton_Click(object sender, EventArgs e)
        {
            try
            {
                baglanti.Open();

                string sorgu = "SELECT Istatistik.*, Oyuncu.Bakiye, OyunlarReferans.OyunAdi, OyunlarReferans.CikisTarihi, IstatistikREF.IstatistikAdi " +
                               "FROM Istatistik " +
                               "INNER JOIN Oyuncu ON Istatistik.KisiNo = Oyuncu.KisiNo " +
                               "INNER JOIN IstatistikREF ON Istatistik.IstatistikID = IstatistikREF.IstatistikID " +
                               "INNER JOIN OyunlarReferans ON IstatistikREF.OyunID = OyunlarReferans.OyunID";

                NpgsqlDataAdapter da = new NpgsqlDataAdapter(sorgu, baglanti);
                DataSet ds = new DataSet();
                da.Fill(ds);

                dataGridView1.DataSource = ds.Tables[0];
            }
            catch (Exception ex)
            {
                MessageBox.Show("Hata: " + ex.Message);
            }
            finally
            {
                baglanti.Close();
            }
        }

        private void MagazaOyunGosterButton_Click(object sender, EventArgs e)
        {
            try
            {
                baglanti.Open();

                string sorgu = "SELECT OyunlarMagaza.*, Yapimci.KisiNo AS YapimciKisiNo, Kisi.Adi AS YapimciAdi, Kisi.Soyadi AS YapimciSoyadi, OyunlarReferans.OyunAdi, OyunlarReferans.CikisTarihi " +
                               "FROM OyunlarMagaza " +
                               "INNER JOIN Yapimci ON OyunlarMagaza.KisiID = Yapimci.KisiNo " +
                               "INNER JOIN Kisi ON Yapimci.KisiNo = Kisi.KisiNo " +
                               "INNER JOIN OyunlarReferans ON OyunlarMagaza.OyunID = OyunlarReferans.OyunID";

                NpgsqlDataAdapter da = new NpgsqlDataAdapter(sorgu, baglanti);
                DataSet ds = new DataSet();
                da.Fill(ds);

                dataGridView1.DataSource = ds.Tables[0];
            }
            catch (Exception ex)
            {
                MessageBox.Show("Hata: " + ex.Message);
            }
            finally
            {
                baglanti.Close();
            }
        }

        private void button2_Click_1(object sender, EventArgs e)
        {
            //Calisan yetki ve departman goruntule
            try
            {
                baglanti.Open();

                // ComboBox'tan seçili olan çalýþanýn KisiNo'sunu al
                int calisanID = (int)comboBoxCalisanID.SelectedValue;

                string sorgu = "SELECT Kisi.KisiNo, Kisi.Adi AS KisiAdi, Kisi.Soyadi AS KisiSoyadi, " +
                               "Kisi.AktifMi, Il.IlAdi AS IlAdi, Calisan.YetkiNo, Yetkiler.YetkiAdi, " +
                               "Calisan.DepartmanNo, Departman.DepartmanAdi " +
                               "FROM Calisan " +
                               "JOIN Kisi ON Calisan.KisiNo = Kisi.KisiNo " +
                               "JOIN Il ON Kisi.IlNo = Il.IlPlaka " +
                               "JOIN Yetkiler ON Calisan.YetkiNo = Yetkiler.YetkiID " +
                               "JOIN Departman ON Calisan.DepartmanNo = Departman.DepartmanID " +
                               "WHERE Calisan.KisiNo = @calisanID";

                NpgsqlCommand komut = new NpgsqlCommand(sorgu, baglanti);
                komut.Parameters.AddWithValue("@calisanID", calisanID);

                NpgsqlDataAdapter da = new NpgsqlDataAdapter(komut);
                DataSet ds = new DataSet();
                da.Fill(ds);

                dataGridView1.DataSource = ds.Tables[0];
            }
            catch (Exception ex)
            {
                MessageBox.Show("Hata: " + ex.Message);
            }
            finally
            {
                baglanti.Close();
            }
        }

        private void button7_Click(object sender, EventArgs e)
        {
            //bakiye guncelleme
            try
            {
                // Seçili oyuncunun ID'sini al
                int oyuncuID = (int)comboBoxOyuncuID.SelectedValue;

                // Yeni bakiye deðerini al
                int yeniBakiye = Convert.ToInt32(textBoxYeniBakiye.Text);

                baglanti.Open();

                using (NpgsqlCommand komut = new NpgsqlCommand("UPDATE Oyuncu SET bakiye = @YeniBakiye WHERE kisino = @OyuncuID", baglanti))
                {
                    komut.Parameters.AddWithValue("@YeniBakiye", yeniBakiye);
                    komut.Parameters.AddWithValue("@OyuncuID", oyuncuID);

                    komut.ExecuteNonQuery();
                    MessageBox.Show("Bakiye güncellendi.");
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Hata: " + ex.Message);
            }
            finally
            {
                baglanti.Close();
            }
        }

        private void button8_Click(object sender, EventArgs e)
        {
            //Bakiye Log goruntule
            try
            {
                baglanti.Open();

                // OyuncuLog tablosundaki verileri çek
                string sorgu = "SELECT * FROM logBakiye";
                NpgsqlDataAdapter da = new NpgsqlDataAdapter(sorgu, baglanti);
                DataSet ds = new DataSet();
                da.Fill(ds);

                // DataGridView üzerinde görüntüle
                dataGridView1.DataSource = ds.Tables[0];
            }
            catch (Exception ex)
            {
                MessageBox.Show("Hata: " + ex.Message);
            }
            finally
            {
                baglanti.Close();
            }
        }

        private void OyunSatinAlButton_Click(object sender, EventArgs e)
        {
            try
            {
                // Seçilen oyunun ID'sini ve oyuncunun ID'sini al
                int secilenOyunID = comboBoxOyun.SelectedIndex+1;
                int oyuncuID = (int)comboBoxOyuncuID.SelectedValue;
                

                // Baðlantýyý aç
                baglanti.Open();

                // Satýn alma iþlemini gerçekleþtir
                using (NpgsqlCommand komut = new NpgsqlCommand("SELECT SatinAlmaIslemi(@p_KisiNo, @p_OyunID)", baglanti))
                {
                    komut.Parameters.AddWithValue("@p_KisiNo", oyuncuID);
                    komut.Parameters.AddWithValue("@p_OyunID", secilenOyunID);

                    // Fonksiyonu çaðýr
                    komut.ExecuteNonQuery();

                    MessageBox.Show("Oyun satýn alma iþlemi baþarýyla tamamlandý.");
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Hata: " + ex.Message);
            }
            finally
            {
                // Baðlantýyý kapat
                baglanti.Close();
            }






        }

        private void comboBoxOyun_SelectedIndexChanged(object sender, EventArgs e)
        {

        }

        private void ArkadaslikGonderVeKabulEtButton_Click(object sender, EventArgs e)
        {
            //arkadaslikKabulEt
            try
            {
                // Baðlantýyý aç
                baglanti.Open();
              
                // Seçilen arkadaþlýk isteðinin ID'sini al
                int arkadaslikID = (int)comboBoxArkadaslikIstekleri.SelectedValue;

                // Arkadaþlýk isteðini kabul et
                using (NpgsqlCommand komut = new NpgsqlCommand("SELECT ArkadaslikIstegiKabulEt(@p_ArkadaslikID);", baglanti))
                {
                    komut.Parameters.AddWithValue("@p_ArkadaslikID", arkadaslikID);

                    // Fonksiyonu çaðýr
                    komut.ExecuteNonQuery();

                    MessageBox.Show("Arkadaþlýk isteði kabul edildi.");
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Hata: " + ex.Message);
            }
            finally
            {
                // Baðlantýyý kapat
                baglanti.Close();
            }
        }

        private void ArkadaslikGonder_Click(object sender, EventArgs e)
        {
            //Ardakaslik gonder
            try
            {
                // Baðlantýyý aç
                baglanti.Open();

            ;

        
                // Arkadaþlýk isteði gönder
                using (NpgsqlCommand komut = new NpgsqlCommand("SELECT ArkadaslikIstegiGonder(@p_GonderenKisiNo, @p_AlanKisiNo)", baglanti))
                {
                    komut.Parameters.AddWithValue("@p_GonderenKisiNo", (int)comboBoxKullanicilar1.SelectedValue);
                    komut.Parameters.AddWithValue("@p_AlanKisiNo", (int)comboBoxKullanicilar2.SelectedValue);

                    // Fonksiyonu çaðýr
                    komut.ExecuteNonQuery();

                    
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Hata: " + ex.Message);
            }
            finally
            {
                // Baðlantýyý kapat
                baglanti.Close();
            }


            try
            {
                string sorgu = "SELECT ArkadaslikID FROM ArkadasKayit";
                NpgsqlCommand komut = new NpgsqlCommand(sorgu, baglanti);
                using (NpgsqlDataAdapter da = new NpgsqlDataAdapter(komut))
                {
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    // ComboBox'ý doldur
                    comboBoxArkadaslikIstekleri.DisplayMember = "arkadaslikid";
                    comboBoxArkadaslikIstekleri.ValueMember = "arkadaslikid";
                    comboBoxArkadaslikIstekleri.DataSource = dt;
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Hata: " + ex.Message);
            }
            finally
            {
                // Baðlantýyý kapat
                baglanti.Close();
            }
        }

        private void OyuncuBasariEkleButton_Click(object sender, EventArgs e)
        {
            
            try
            {
                using (NpgsqlCommand command = new NpgsqlCommand("SELECT OyuncuIstatistikEkle(@p_KisiNo, @p_IstatistikID)", baglanti))
                {
                    // ComboBox'lardan seçilen deðerleri al
                    int kisiNo = (int)comboBoxOyuncuID.SelectedValue;
                    int istatistikID = comboBoxIstatistik.SelectedIndex+1;

                    // Parametreleri ekleyerek saklý yordamý çaðýr
                    command.Parameters.AddWithValue("@p_KisiNo", kisiNo);
                    command.Parameters.AddWithValue("@p_IstatistikID", istatistikID);

                    baglanti.Open();
                    command.ExecuteNonQuery();

                    MessageBox.Show("Oyuncu istatistikleri eklendi.");
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Hata: " + ex.Message);
            }
            finally
            {
                baglanti.Close(); ;
            }
        }

        private void ArkadaslikTablosunuEkranaBasButton_Click(object sender, EventArgs e)
        {
            try
            {
               
                    baglanti.Open();

                    string sorgu = "SELECT * FROM ArkadasKayit";

                    NpgsqlDataAdapter da = new NpgsqlDataAdapter(sorgu, baglanti);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    // DataGridView'e verileri yükle
                    dataGridView1.DataSource = dt;
                
            }
            catch (Exception ex)
            {
                MessageBox.Show("Hata: " + ex.Message);
            }
            finally
            {
                baglanti.Close();
            }
        }

        private void BakiyeYukseltButton_Click(object sender, EventArgs e)
        {
            try
            {
                // Baðlantýyý aç
                baglanti.Open();

                // TextBox'tan girilen bakiye limitini al
                int bakiyeLimit = Convert.ToInt32(TextBoxBakiyeYukselt.Text);

                // Saklý yordamý çaðýr
                using (NpgsqlCommand komut = new NpgsqlCommand("bakiyearttir", baglanti))  // Saklý yordam adýný doðrudan kullan
                {
                    komut.CommandType = CommandType.StoredProcedure;
                    komut.Parameters.AddWithValue("@p_bakiyelimit", bakiyeLimit);  // Küçük harfle parametre adýný kullan

                    // Saklý yordamý çalýþtýr
                    komut.ExecuteNonQuery();

                    MessageBox.Show("Bakiyesi belirli limitin altýnda olan oyuncularýn bakiyeleri iki katýna çýkarýldý.");
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Hata: " + ex.Message);
            }
            finally
            {
                // Baðlantýyý kapat
                baglanti.Close();
            }
        }
    }
}