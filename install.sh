#!/bin/sh

# الانتقال إلى مجلد /tmp
cd /tmp

# تنزيل الملف من الرابط المباشر
wget -O /tmp/Uni_stalker.tar.gz "https://github.com/MARKETTV1/Uni_Stalker/raw/refs/heads/main/Uni_stalker.tar.gz"

# فك الضغط عن الملف
tar -xzvf /tmp/Uni_stalker.tar.gz

# نقل المحتويات الى extension
mv /tmp/files/* /Extensions/

# تعديل الصلاحيات (اختياري)
chmod -R 644 /Uni_stalker/*

# تنظيف الملفات المؤقتة (اختياري)
rm -rf /tmp/Uni_stalker.tar.gz /tmp/files

# إعادة التشغيل (اختياري)
reboot
