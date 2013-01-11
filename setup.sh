#!/bin/sh

svn co -r 31639 svn://svn.openwrt.org/openwrt/trunk openwrt || exit 1

cd openwrt

[ ! -e feeds.conf ] && cp -v ../feeds.conf feeds.conf
[ ! -e files ] && mkdir files
[ ! -e dl ] && mkdir ../dl && ln -sf ../dl dl
cp -rf -v ../default-files/* files/
if ! grep -q commotion feeds.conf; then
    echo "adding commotion package feed..."
    echo "src-link commotion ../../commotionfeed" >> feeds.conf
fi

scripts/feeds update -a
scripts/feeds install -a
for i in $(ls ../commotionfeed/); do scripts/feeds install $i; done

# Copy in Commotion-specific patches
cp -v ../patches/910-fix-out-of-bounds-index.patch feeds/packages/utils/collectd/patches/
cp -v ../patches/890_ath9k_advertize_beacon_int_infra_match.patch package/mac80211/patches
cp -v ../patches/891_ath9k_htc_advertize_allowed_vif_combinations.patch package/mac80211/patches
cp -v ../patches/892_ath9k_htc_remove_interface_combination_specific_checks.patch package/mac80211/patches
cp -v ../patches/893_mac80211_add_supported_rates_change_notification_ibss.patch package/mac80211/patches
cp -v ../patches/894_ath9k_htc_implement_sta_rc_update_mac80211_callback.patch package/mac80211/patches
cp -v ../config .config

echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo " Commotion OpenWrt is prepared. To build the firmware, type:"
echo " cd openwrt"
echo " make menuconfig #If you wish to add or change packages."
echo " make V=99"
