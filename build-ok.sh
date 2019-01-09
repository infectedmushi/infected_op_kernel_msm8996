KBUILD_OUTPUT=/mnt/Building/out
MODULES_DIR=/mnt/Building/AnyKernel2-franco/modules/vendor/lib/modules

cd /mnt/Building/francokernel
export USE_CCACHE=1
export VARIANT="OOS-P-R41"
export HASH=`git rev-parse --short=8 HEAD`
export KERNEL_ZIP="FrancoKernel-$VARIANT-$(date +%y%m%d)-$HASH"
export LOCALVERSION=~`echo $KERNEL_ZIP`H
export ARCH=arm64
export CROSS_COMPILE="/mnt/Building/gcc-arm-8.2-2018.11-x86_64-aarch64-linux-gnu/bin/aarch64-linux-gnu-"
make O=../out clean
make O=../out mrproper
make O=../out franco_defconfig
make -j$(nproc --all) O=../out  
cd /mnt/Building/out
find $KBUILD_OUTPUT -name '*.ko' -exec cp -v {} $MODULES_DIR \;
${CROSS_COMPILE}strip --strip-unneeded $MODULES_DIR/*.ko
find $MODULES_DIR -name '*.ko' -exec $KBUILD_OUTPUT/scripts/sign-file sha512 $KBUILD_OUTPUT/certs/signing_key.pem $KBUILD_OUTPUT/certs/signing_key.x509 {} \;
/mnt/Building/out/scripts/sign-file sha512 /mnt/Building/out/certs/signing_key.pem /mnt/Building/out/certs/signing_key.x509 *.ko
## copy assets
cp -v *.ko /mnt/Building/AnyKernel2-franco/modules/vendor/lib/modules
cd $KBUILD_OUTPUT/arch/arm64/boot
cp -v Image.gz-dtb /mnt/Building/AnyKernel2-franco/zImage                     
cd /mnt/Building/AnyKernel2-franco
zip -r9 $KERNEL_ZIP.zip *
mv -v $KERNEL_ZIP.zip /mnt/Building/Out_Zips
echo "Done!!!"
