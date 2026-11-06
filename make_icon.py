from PIL import Image, ImageDraw, ImageFont
import arabic_reshaper
from bidi.algorithm import get_display

# إنشاء صورة 512x512 (المقاس المعتمد للأيقونات)
img = Image.new('RGB', (512, 512), color='#e75480') # خلفية وردية
d = ImageDraw.Draw(img)

# رسم قلب أبيض في المنتصف
d.polygon([(256, 400), (100, 200), (160, 120), (256, 190), (352, 120), (412, 200)], fill='white')

# تجهيز النص العربي
text = "محمد وهديل"
reshaped_text = arabic_reshaper.reshape(text)
bidi_text = get_display(reshaped_text)

# تحميل الخط العربي
font = ImageFont.truetype("assets/Amiri-Regular.ttf", 65)

# حساب مكان النص عشان يكون في المنتصف تحت القلب
bbox = d.textbbox((0, 0), bidi_text, font=font)
text_width = bbox[2] - bbox[0]
x = (512 - text_width) / 2
y = 430

# كتابة النص
d.text((x, y), bidi_text, font=font, fill='white')

# حفظ الصورة
img.save('assets/icon.png')
print("✅ تم إنشاء الأيقونة في assets/icon.png")
