// SPDX-License-Identifier: MIT
pragma solidity >=0.4.4 < 0.7.0;
pragma experimental ABIEncoderV2;
import "./SafeMath.sol";

//Cristian   --->   0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
//Francisco  ---->  0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
//Angel   ---->     0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db


//Interface de nuestro token ERC20
interface IERC20{ 

   //Devuelve la cantidad de tokens en existencia
 function totalSupply() external view returns (uint256);

   //Devuelve la cantidad de tokens para una direccion indicada por parametros
 function balanceOf(address account) external view returns (uint256);

   //Devuelve el numero de token que el spender podra gastar en nombre del propietario (owner)
 function allowance(address owner, address spender) external view returns (uint256);

   //Devuelve un valor Booleano resultado de la operacion indicada
 function transfer(address recipient, uint256 amount) external returns (bool);
 
   //Disney
 function transferencia_disney(address _cliente, address recipient, uint256 amount) external returns (bool);

   //Devuelve un valor booleano con el resultado de la operacion de gasto
 function approve(address spender, uint256 amount) external returns (bool);

   //Devuelve un valor booleano con el resultado de la operacion de paso de una cantidad de tokens usando el metodo allowance()
 function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


   //Evento que se debe emitir cuando una cantidad de token pase de un origen a un destino
 event Transfer(address indexed from, address indexed to, uint256 value);  

   //Evento que se debe emitir cuando se establece una asignacion con el metodo allowance o DELEGACION.
 event Approval(address indexed owner, address indexed spender, uint256 value);
}
//Implementacion de las funciones del token ERC20 
contract ERC20Basic is IERC20{
  
  string public constant name = "MICKEY COIN";
  string public constant symbol = "DISNEY";
  uint8 public constant decimal = 2;  

  event Transfer(address indexed from, address indexed to, uint256 tokens);
  event Approval(address indexed owner, address indexed spender, uint256 tokens);


 using SafeMath for uint256;

    mapping (address => uint) balances;
    mapping (address => mapping (address =>uint)) allowed;
    uint totalSupply_;  

    constructor (uint256 initialSupply) public{
      totalSupply_ = initialSupply;
      balances[msg.sender] = totalSupply_;  //Constructor es el constructor del smartcontract y decide cuanto es el TotalSupply_. Aun asi, se pueden minar nuevos tokens.
    }

    function totalSupply() public override view returns (uint256){
        return totalSupply_;   //Esto seria un reflejo del totalSupply para que no se pueda modificar, solo el contractor puede.
    }

    function increaseTotalSupply(uint newTokensAmount) public{   //mineria 
      totalSupply_ += newTokensAmount;
      balances[msg.sender] += newTokensAmount;
    }
    
    function balanceOf(address tokenOwner) public override view returns (uint256){
        return balances[tokenOwner];  //ver el balance del tokenOwner solo.
    }

    function allowance(address owner, address delegate) public override view returns (uint256){
        return allowed[owner][delegate]; //Nos permite comprobar el balance, de la cantidad que ha sido delegada a nosotros y se nos permite gastar.
    }

    function transfer(address recipient, uint256 numTokens) public override returns (bool){
        require(numTokens <= balances[msg.sender]); //Confirmar que el numero de tokens que queremos enviar sea igual o inferior al balance del msg.sender.
        balances[msg.sender] = balances[msg.sender].sub(numTokens); //El envio y resta de los tokens enviados. TRANSACCION
        balances[recipient] = balances[recipient].add(numTokens); //El recibo o suma de os tokens recibidos
        emit Transfer(msg.sender, recipient, numTokens); //Emision, notificacion publica
        return true;
    }

    // Disney, transferrencia desde el cliente y no desde el contrato como es en el anterior function de transer.
    function transferencia_disney(address _cliente, address recipient, uint256 numTokens) public override returns (bool){
        require(numTokens <= balances[_cliente]); //Confirmar que el numero de tokens que queremos enviar sea igual o inferior al balance del msg.sender.
        balances[_cliente] = balances[_cliente].sub(numTokens); //El envio y resta de los tokens enviados. TRANSACCION
        balances[recipient] = balances[recipient].add(numTokens); //El recibo o suma de os tokens recibidos
        emit Transfer(_cliente, recipient, numTokens); //Emision, notificacion publica
        return true;
    }


    function approve(address delegate, uint256 numTokens) public override returns (bool){  //DELAGACION a otra persona para que pueda hacer X con los tokens. Pero siguen siendo tuyos.
        allowed[msg.sender][delegate] = numTokens;  //El Permiso de Delegacion.
        emit Approval(msg.sender, delegate, numTokens); //Emision, notificacion publica
        return true;
    }

    function transferFrom(address owner, address buyer, uint256 numTokens) public override returns (bool){
        require(numTokens <= balances[owner]);  //Confirmacion de que los tokens que se quieren vender son igual o menos al balance del owner.
        require(numTokens <= allowed[owner][msg.sender]);  //Confirmacion que el numTokens que queremos enviar es igual o inferior al numero que se han delegado. El onwer puede tener 10 tokens en su address, pero solo se nos han delegado 2.
        
        balances[owner] = balances[owner].sub(numTokens);  //Se quita al propietario actual.
        allowed[owner][msg.sender] = allowed[owner][msg.sender].sub(numTokens); //Se quita la delegacion.
        balances[buyer] = balances[buyer].add(numTokens);  //Se suma al nuevo propietario.
        emit Transfer(owner, buyer, numTokens);
        return true;
    }
}
