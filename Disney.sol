pragma solidity >0.4.4 <0.7.0;
pragma experimental ABIEncoderV2;
import "./ERC20.sol"; //Importamos el Token con SafeMath.sol ya dentro

contract Disney{

      // -------------------------------------------------- DECLARACIONES INICIALES ------------------------

//Instancia o llamada del contrato de los tokens
    ERC20Basic private token;


//Direccion de Disney (Owner)
    address payable public owner;


 //Constructor
    constructor () public {
        token = new ERC20Basic(10000);
        owner = msg.sender;
    } 
   
// Estructura de datos para almacenar a los clientes de Disney
    struct cliente {
        uint tokens_comprados;
        string [] atracciones_disfrutadas;
    }
  
// Mapping para el registro de clientes
    mapping (address => cliente) public Clientes;

        // ----------------------------------------------------- GESTION DE TOKENS---------------------------------------

//Funcion para establecer el precio de un Token
    function PrecioTokens(uint _numTokens) internal pure returns (uint) {
        return _numTokens*(1 ether);    //Conversion de tokens a Ethers: 1 Token -> 1 ether

    }

//Funcion para comprar tokens en disney y disfrutar de las actracciones
    function CompraTokens(uint _numTokens) public payable {
        uint coste = PrecioTokens(_numTokens);  //Establecer el precio de los Tokens
        require (msg.value >= coste, "Compra menos Tokens o paga con mas ethers.");  //Se evalua el dinero que el cliente paga por los Tokens, este caso por la entrada de Disney, tiene que dar igual o mas.
        uint returnValue = msg.value - coste;  //Diferencia de la parte extra que se ha pagado o si paga justo no se devolveria nada.
        msg.sender.transfer(returnValue);  //Devolucion de la diferencia.
        uint Balance = balanceOf();  //Obtencion del numero de tokens disponibles. Balance actualizado y controlado.
        require(_numTokens <= Balance, "Compra un numero menor de Tokens");  //El numero de tokens debe de ser igual o inferior al balance total del numero de tokens disponibles
        token.transfer(msg.sender, _numTokens);  //Se transfiere el numero de tokens al cliente
        Clientes[msg.sender].tokens_comprados += _numTokens;   //Registro de tokens comprados
    }

//Balance de tokens del contrato disney, publico para que la gente pueda ver los tokens que quedan disponibles     
    function balanceOf() public view returns (uint) {
        return token.balanceOf(address(this));
    }

//Visualizacion del numero de tokens restantes de un cliente
    function MisTokens() public view returns (uint){
       return token.balanceOf(msg.sender);
    }

//Funcion para generar mas tokens, por si la demanda lo solicita
     function GeneraTokens(uint _numTokens) public Unicamente(msg.sender) {
        token.increaseTotalSupply(_numTokens);
    }
    
//Modificador para controlar las funciones ejecutables por Disney
    modifier Unicamente(address _direccion) {
        require(_direccion == owner, "No tienes permisos para ejecutar esta funcion");
        _;
    }


        // ----------------------------------------------------- GESTION DE TOKENS---------------------------------------

// Eventos
    event disfruta_atraccion(string, uint, address);
    event nueva_atraccion(string, uint, uint, uint);
    event baja_atraccion(string);
//---
  event disfruta_comida(string, uint, address);
    event nueva_comida(string, uint, bool);
    event baja_comida(string);

//Estructura de datos de la atraccion
    struct atraccion{
        string nombre_atraccion;
        uint precio_atraccion;
        uint velocidad_maxima;
        uint aforo_maximo;
        bool estado_atraccion;
    }
 //--  
//Estructura de datos de la comida
    struct Comida{
        string nombre_comida;
        uint precio_comida;
        bool estado_comida;
    }

// Mapping para relacionar un nombre de una atraccion con una estructura de datos de la atraccion
    mapping (string => atraccion) public MappingAtracciones;

//---
//Mapping para relacionar un nombre de comida con una estructura de dats.
    mapping (string => Comida) public MappingComidas;

//Array para almacenar el nombre de las comidas
    string [] Atracciones;
//---

//Array para almacenar el nombre de las atracciones
    string [] Comidas;

//Mapping para relacionar una identidad con su historial en Disney. Saber lo que hace el cliente.
    mapping (address => string[]) HistorialAtracciones;

//Mapping para relacionar una identidad con su historial de comidas en Disney. Saber lo que hace el cliente.
    mapping (address => string[]) HistorialComidas;

// FUNCION crear nuevas atracciones y dar valor. Debemos tratarlos como si fueran peajes, ya que cobran.(Solo es Ejecutable por Disney)

// Star Wars -> 2 Tokens, 100 KM, 105
// Toy Story -> 5 Tokens, 15 KM, 500
// Piratas del Caribe -> 8 Tokens, 50KM, 300
    function NuevaAtraccion(string memory _nombreAtraccion, uint _precio, uint _velocidad_maxima, uint aforo_maximo) public Unicamente(msg.sender){
       MappingAtracciones[_nombreAtraccion] = atraccion(_nombreAtraccion, _precio, _velocidad_maxima, aforo_maximo, true);    //Creacion de una atraccion en Disney
       Atracciones.push(_nombreAtraccion);   //Almacenamiento en un array el nombre de la atraccion
       emit nueva_atraccion(_nombreAtraccion, _precio, _velocidad_maxima, aforo_maximo); //Emision del evento para la nueva atraccion.
    }
//---  
    function NuevaComida(string memory _nombreComida, uint _precio) public Unicamente(msg.sender){
       MappingComidas[_nombreComida] = Comida(_nombreComida, _precio, true);    //Creacion de una comida en Disney
       Comidas.push(_nombreComida);   //Almacenamiento en un array el nombre de la comida
       emit nueva_comida(_nombreComida, _precio, true); //Emision del evento para la nueva comida.
    }


// FUNCION dar de baja atracciones de Disney. Solo disney puede hacerlo.
    function BajaAtracciones(string memory _nombreAtraccion) public Unicamente(msg.sender){ 
       MappingAtracciones[_nombreAtraccion].estado_atraccion = false; //El estado de la atraccion pasa a FALSE => No uso
       emit baja_atraccion(_nombreAtraccion);
    }
//---
   function BajaComidas(string memory _nombreComida) public Unicamente(msg.sender){ 
       MappingComidas[_nombreComida].estado_comida = false; //El estado de la comida pasa a FALSE => No uso
       emit baja_comida(_nombreComida);
    }

//Funcion para Visualizar las atraccions de Disney
   function AtraccionesDisponibles() public view returns (string [] memory){
        return Atracciones;
    }

//Funcion para subirse a una atraccion de disney y pagar en tokens
    function SubirseAtraccion (string memory _nombreAtraccion) public{
        uint tokens_atraccion = MappingAtracciones[_nombreAtraccion].precio_atraccion; //Precio de la atraccion en tokens
        require (MappingAtracciones[_nombreAtraccion].estado_atraccion == true, "La atraccion no esta disponible en estos momentos"); //Verifica el estado de la atraccion ( si esta disponible para su uso)
        require (tokens_atraccion <= MisTokens(), "Necesitas mas Tokens para subirte a esta atraccion"); //Verificar el numero de tokens que tiene el cliente para subir a la atraccion.

      /*El cliente paga la atraccion en Tokens:
      -Ha sido necesario crear/añadir una funcion ERC20.sol con el nombre de : ´Transferencia_disney´
      debido a que en caso de usar el Transfer o TranferFrom las direcciones que se escogian
      para realizar la transaccion eran equivocadas. Ya que el msg.sender que recibia el metodo de Transfer o TransferFrom
      era la direccion del contrato y no del cliente.*/
        token.transferencia_disney(msg.sender, address(this), tokens_atraccion);
        HistorialAtracciones[msg.sender].push(_nombreAtraccion); //Almacenamiento en el historial de atracciones del cliente.
        emit disfruta_atraccion(_nombreAtraccion, tokens_atraccion, msg.sender);
    }
//--
  function ComprarComida (string memory _nombreComida) public{
        uint tokens_comida = MappingComidas[_nombreComida].precio_comida; //Precio de la comida en tokens
        require (MappingComidas[_nombreComida].estado_comida == true, "La comida no esta disponible en estos momentos"); //Verifica el estado de la atcomidaraccion ( si esta disponible para su uso)
        require (tokens_comida <= MisTokens(), "Necesitas mas Tokens para comprar la comida"); //Verificar el numero de tokens que tiene el cliente para subir a la atraccion.

      /*El cliente paga la atraccion en Tokens:
      -Ha sido necesario crear/añadir una funcion ERC20.sol con el nombre de : ´Transferencia_disney´
      debido a que en caso de usar el Transfer o TranferFrom las direcciones que se escogian
      para realizar la transaccion eran equivocadas. Ya que el msg.sender que recibia el metodo de Transfer o TransferFrom
      era la direccion del contrato y no del cliente.*/
        token.transferencia_disney(msg.sender, address(this), tokens_comida);
        HistorialComidas[msg.sender].push(_nombreComida); //Almacenamiento en el historial de atracciones del cliente.
        emit disfruta_comida(_nombreComida, tokens_comida, msg.sender);
    }    

//Funcion para visualizar el historial completo de atracciones disfrutadas por un cliente.
    function Historialatractions() public view returns (string [] memory) {
        return HistorialAtracciones[msg.sender];
    }
//--
//Funcion para visualizar el historial completo de comidas disfrutadas por un cliente.
    function HistorialFood() public view returns (string [] memory) {
        return HistorialComidas[msg.sender];
    }

//Funcion para que un cliente de Disney pueda devolver tokens por Ether en cualquier momento.
    function DevolverTokens (uint _numTokens) public payable {
        require (_numTokens > 0, "Necesitas devolver una cantidad positiva de tokens."); //Verificar que el numero de tokens a devolver es positivo.
        require (_numTokens <= MisTokens(), "No tienes los tokenss que deseas devolver."); //Verificar que la cantidad que el cliente quiere devolver, el cliente lo tiene.
        token.transferencia_disney(msg.sender, address(this), _numTokens);  //El cliente devuelve los tokens. (Funcion llamada del contracto ERC20)
        msg.sender.transfer(PrecioTokens(_numTokens));  //Devolucion de los Ethers al cliente
    }

}