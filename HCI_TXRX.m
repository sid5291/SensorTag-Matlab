function [result] = HCI_TXRX(data,type)
    ADDRESS_TYPE  = 1;
    if(nargin < 2)
        type = 0;
    end
    s = serial('COM13');
    set(s,'BaudRate',115200,'Timeout',0.2,'FlowControl','none','Parity','none');
    dec=hex2dec(data);
    fopen(s);
    fwrite(s,char(dec)');
    if(type == 1)
       temp_h = dec2hex(0,2);
       i = 1;
       while (1)
           temp = fread(s,1);
           if(isempty(temp))
               continue;
           end
           temp_h = [temp_h; dec2hex(temp,2)];
           i =i+1;
           if(strcmp(temp_h(i-1,:),'01') && strcmp(temp_h(i,:),'06'))% Discovery Done
               break;
           end
       end
    end
    tic;
    while(toc < 2)
    end
    [A,count] = fread(s);
    fclose(s);
    h=dec2hex(A);
    if(type==1)
        h = [temp_h;h];
    end
    disp('Raw Data:')
    Hex_disp(h);
    i = 1;
    while(i<=length(h))
        if(h(i,:) == '04')
                data_length = hex2dec(h(i+2,:));
                i = i+3;
                payload = h(i:(data_length+i-1),:);
                i = i + (data_length-1);
                disp('Payload:')
                Hex_disp(payload);
                if(payload(3,:) == '00')
                    disp('Success')
                    if(type == 1)
                        if(strcmp(payload(1,:),'01') && strcmp(payload(2,:),'06')) % Discovery Done
                            disp('Discovery Done')
                            devices = hex2dec(payload(4,:));
                            fprintf('Number of Devices %d\n',devices);
                            disp('Addresses');
                            size = length(payload);
                            for m = 1:devices
                                address = payload(size-5:size,:); % 6 byte MAC Address 
                                fprintf('Device %d MAC Address(reversed):\n',m);
                                Hex_disp(address,ADDRESS_TYPE)
                                size = size - 8;
                            end
                        end 
                    elseif(type == 4)
                        if(strcmp(payload(1,:),'0B') &&strcmp(payload(2,:),'05'))  % GATT_ReadRsp
                            result = payload((length(payload)-3):length(payload),:);
                            disp('Raw Result')
                            disp(result)
                        end
                    end
                elseif(payload(3,:)== '12')
                    disp('Not in Correct State')
                elseif(payload(3,:) == '11')
                    disp('Already Performing task')
                else
                    disp ('Error')
                end
        end
        i=i+1;
    end     
end
