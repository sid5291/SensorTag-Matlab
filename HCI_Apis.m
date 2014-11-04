GAP_initialise=['01';'00';'FE';'26';'08';'05';'00';'00';'00';'00';'00';'00';'00'
'00';'00';'00';'00';'00';'00';'00';'00';'00';'00';'00';'00';'00'
'00';'00';'00';'00';'00';'00';'00';'00';'00';'00';'00';'00';'01'
'00';'00';'00'];
GAP_DeviceDiscovery = ['01';'04';'FE';'03';'03';'01';'00'];
SCAN_TYPE = 1;
GAP_connect = ['01'; '09'; 'FE'; '09'; '00'; '00'; '00' ;'46';'50'; 'AC' ;'29' ;'6A' ;'BC'];  %BC:6A:29:AC:50:46 (1325 Tag)
CONNECT_TYPE = 2;
% Reference http://processors.wiki.ti.com/images/a/a8/BLE_SensorTag_GATT_Server.pdf
GATT_IRTempOn = ['01'; '92'; 'FD'; '05'; '00'; '00'; '29'; '00'; '01'];
GATT_IRTempOff = ['01'; '92'; 'FD'; '05'; '00'; '00'; '29'; '00'; '00'];
GATT_HumidOn = ['01'; '92'; 'FD'; '05'; '00'; '00'; '3F'; '00'; '01'];
GATT_HumidOff = ['01'; '92'; 'FD'; '05'; '00'; '00'; '3F'; '00'; '00'];
WRITE_TYPE = 3;
GATT_IRTempRd = ['01'; '8A'; 'FD'; '04'; '00'; '00'; '25' ;'00' ];
GATT_HumidRd = ['01'; '8A'; 'FD'; '04'; '00'; '00'; '3B' ;'00' ];
READ_TYPE = 4;

disp('Going to Intialize');
HCI_TXRX(GAP_initialise);
disp('Going to Scan');
disp('Make Sure Led D1 is blinking on Sensor Tag');
disp('Wait for Scan To End');
input('Press any key to continue');
HCI_TXRX(GAP_DeviceDiscovery,SCAN_TYPE);
disp('Going to Connect to Sensor Tag');
disp('LED D1 will turn off when Connected, if doesnt there is an error');
input('Press any key to continue');
HCI_TXRX(GAP_connect,CONNECT_TYPE);
disp('Going to Turn On IR');
input('Press any key to continue');
HCI_TXRX(GATT_IRTempOn,WRITE_TYPE);
disp('Going to Turn On Humiditiy');
input('Press any key to continue');
HCI_TXRX(GATT_HumidOn,WRITE_TYPE);
disp('Going to Read from Sensors');
input('Press any key to continue');
while(1)
    result = HCI_TXRX(GATT_IRTempRd,READ_TYPE);
    rawobjtemp = hex2dec([result(2,:); result(1,:)]);
    rawambtemp = hex2dec([result(4,:); result(3,:)]);
    ambtemp = (rawambtemp(1)*256+rawambtemp(2))/128.0; % in C
    fprintf('Ambient Temp: %f \n',ambtemp);
    char = input('Press any key to continue (x to exit)','s');
    if(char == 'x')
        break;
    end
    result = HCI_TXRX(GATT_HumidRd,READ_TYPE);
    rawhumtemp = hex2dec([result(2,:); result(1,:)]);
    rawhum = hex2dec([result(4,:); result(3,:)]);
    humtemp = -46.85 + ((175.72/65536) * (rawhumtemp(1)*256+rawhumtemp(2)));
    rawhum(2) = rawhum(2) & (~3);
    relativehum = -6.0 + ((125.0/65536)*(rawhum(1)*256+rawhum(2)));
    fprintf('Humidity Temp: %f \n',humtemp);
    fprintf('Relative Humidity: %f \n',relativehum);
    char = input('Press any key to continue (x to exit)','s');
    if(char=='x')
        break;
    end
end
    

