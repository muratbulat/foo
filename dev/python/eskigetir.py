import requests
from pyquery import PyQuery

###### NOTLAR VE BİLGİ GİRİŞİ ######
print()
print("Programı Kullandığınız İçin Teşekkürler!\nŞimdi Girmeniz Gereken 3 Bilgi Girişi Var.\nBunları Girerek Entry'nin Hangi Sayfa Numarasında Olduğunu Bulabilirsiniz.\nUnutmayın! Bu Program Profesyonelce Yazılmamıştır. Çıkan Sonuç O Sayfanın 1 İleri/Gerisinde Olabilir Hatta Hiç Orada Da Olmayabilir.")
print()
link = input("Lütfen Aratmak İstediğiniz Başlığın Şükela(Tümü) Linkini Yapıştırıp Enter Tuşuna Basın:")
eid = input("Aratmak İstediğiniz Entry'nin Numarasını Girin:")
numara = input("Başlığın İlk Kaç Sayfasında Arama Yapılsın?:")
print("Arama Başladı")
print()
###### NOTLAR VE BİLGİ GİRİŞİ ######

headers = {'User-Agent':"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/103.0.0.0 Safari/537.36"}

kapat = False

for i in range(1,int(numara)+1):
    url = link+"&p="+str(i)

    r = requests.get(url,headers=headers)
    pq = PyQuery(r.text)

    tag = pq('#container')('#main')('#content')('#content-body')('#topic')('ul#entry-item-list')
    for tara in tag('li').items():
        if(tara.attr('data-id'))==eid:
            print("Değer Bulundu. Entry'nin Şükela Sayfası: "+str(i))
            kapat = True
            break
    if kapat:
        break
print("Tarama Sona Erdi")
input()
