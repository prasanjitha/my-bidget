# Device Pairing විශේෂාංගය

## සාරාංශය
මෙම feature එක මගින් ඔබට Google Sign-In නැතිව devices දෙකක් හෝ වැඩි ගණනක ඔබේ budget data sync කරගන්න පුළුවන්. QR code එකක් scan කරලා devices pair කරගන්නවා.

## භාවිතා කරන ආකාරය

### පළමු Device එක (Primary Device)
1. App එක open කරන්න
2. Fingerprint authentication setup කරන්න
3. Budget app එක භාවිතා කරන්න පටන් ගන්න

### දෙවන Device එක Pair කරගන්න ආකාරය

**පළමු phone එකෙන් (දැනටමත් app එක තියෙන):**
1. Settings වලට යන්න
2. "Pair New Device" එක tap කරන්න
3. QR code එකක් පෙන්වයි

**අලුත් phone එකෙන්:**
1. App එක install කරලා open කරන්න
2. Welcome screen එකේ "Pair with existing device" button එක tap කරන්න
3. පළමු phone එකේ QR code එක scan කරන්න
4. Fingerprint authentication setup කරන්න
5. ඉවරයි! දැන් දෙපාරටම same data එක show වෙයි

## ආරක්ෂාව
- හැම device එකකම වෙන වෙනම fingerprint authentication ඕනෙ
- QR code එකේ තියෙන්නේ userId එක විතරයි (sensitive data නැහැ)
- QR code එක private තියාගන්න - ඒක තියෙන කෙනෙකුට data access කරන්න පුළුවන්
- ඕනෑම වෙලාවක ඕනෑම device එකකින් logout වෙන්න පුළුවන්

## Data Sync කරන විදිය
- හැම වෙනස්කමක්ම automatically real-time වලින් sync වෙනවා
- දෙපාරටම පෙන්නවා:
  - Monthly budget allocation
  - Categories (expense categories)
  - Expenses (විනාශ)
  - Savings (ඉතිරි කිරීම්)
  - Settings (currency, budget cycle, etc.)

## වැදගත්
- දෙපාරටම same Firebase Firestore database එක use කරනවා
- Data එක device එකකින් වෙනස් කළාම, අනිත් device එකෙත් වෙනස් වෙනවා
- Internet connection ඕනෙ sync වෙන්න

## Settings වල තියෙන ඉඩකඩ
Settings වලට ගියාම:
- **"Pair New Device"** - නව device එකක් pair කරගන්න QR code එක generate කරනවා
- දැනටමත් paired devices වල same data sync වෙනවා automatically

## ප්‍රශ්න සහ පිළිතුරු

**Q: මට devices කීයක් pair කරගන්න පුළුවන්ද?**
A: ඕනෑම ගණනක් devices pair කරගන්න පුළුවන්. හැම device එකකම same userId එක use වෙනවා.

**Q: Phone එක lost කළොත් data එක නැති වෙනවද?**
A: නැහැ! දුරකථනය lost කළත්, අනිත් paired devices වල data තිබෙනවා. හැබැයි හැම devices ම lost කළොත් data recover කරගන්න බැහැ.

**Q: QR code එක expire වෙනවද?**
A: නැහැ. QR code එක හැමදාම valid. එකම userId එක use කරනවා.

**Q: Device එකක් unpair කරන්න පුළුවන්ද?**
A: දැන් හැකියාවක් නැහැ. නමුත් ඕනෑම device එකකින් Logout වෙන්න පුළුවන්. ඒත් logout වුණාට පස්සේ ආයෙ QR scan කරලා login වෙන්න පුළුවන්.

**Q: Google Sign-In use කරන්නේ නැද්ද?**
A: නැහැ. මේ app එක local biometric authentication (fingerprint/face ID) විතරයි use කරන්නේ. QR code pairing use කරලා devices sync කරනවා.
