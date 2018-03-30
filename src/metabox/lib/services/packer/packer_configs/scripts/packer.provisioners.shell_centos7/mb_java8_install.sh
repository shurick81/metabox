echo "Installing JAVA - jdk-8u144..."
cd /opt/

JDK_FILE=jdk-8u141-linux-x64.tar.gz
JDK_FOLDER=jdk1.8.0_141

if [ -f $JDK_FILE ]; then
    echo "Already downloaded: jdk-8u144-linux-x64.tar.gz"
else 
    echo "Downloadin: jdk-8u144-linux-x64.tar.gz"

    wget -c -O "jdk-8u141-linux-x64.tar.gz" --no-check-certificate --no-cookies --header \
"Cookie: oraclelicense=accept-securebackup-cookie" \
"http://download.oracle.com/otn-pub/java/jdk/8u141-b15/336fa29ff2bb4ef291e347e091f7f4a7/$JDK_FILE"

    tar xzf $JDK_FILE

    RETVAL=$?
    [ $RETVAL -eq 0 ] && echo "All good, continue..."
    [ $RETVAL -ne 0 ] && echo "Failed to extract $JDK_FILE, probably it does not exist" && exit 1

fi

cd "/opt/$JDK_FOLDER/"

echo "Setting up JAVA alternatives..."
alternatives --install /usr/bin/java java "/opt/$JDK_FOLDER/bin/java" 2
alternatives --install /usr/bin/jar jar "/opt/$JDK_FOLDER/bin/jar" 2
alternatives --install /usr/bin/javac javac "/opt/$JDK_FOLDER/bin/javac" 2

alternatives --set java "/opt/$JDK_FOLDER/bin/java"
alternatives --set jar "/opt/$JDK_FOLDER/bin/jar"
alternatives --set javac "/opt/$JDK_FOLDER/bin/javac"

echo "Showing current java version..."
java -version

RETVAL=$?
[ $RETVAL -eq 0 ] && echo "All good, continue..."
[ $RETVAL -ne 0 ] && echo "Can't see JAVA installed..." && exit 1

echo "Setting up JAVA_HOME, JRE_HOME and PATH"
export JAVA_HOME="/opt/$JDK_FOLDER"
export JRE_HOME="/opt/$JDK_FOLDER/jre"
export PATH=$PATH:/opt/$JDK_FOLDER/bin:/opt/$JDK_FOLDER/jre/bin