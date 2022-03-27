# Payment System for Disney.
Creacion de un sistema de pagos para Disney con Solidity. Creation of a Payment system for Disney with Solidity.

Este Smart Contract esta basado en Disney y puede ser utilizado para cualquier otro parque temático. Los usuarios pueden interactuar con el contracto comprando Tokens que han sido minteados por el Dueño del Smart Contract (Disney) usando el protocolo ERC20.

El Smart Contract esta ajustado por defecto 1 token (MICKEY COIN) = 1 ETH. El propietario del Smart Contract es capaz de hacer ajustes a través de la función "PrecioTokens".

## Resumen

Usuarios pueden comprar el token ERC20 (MICKEY COIN) con sus Ethers para utilizarlos en Disney ya sea para la compra de alimentos como para subir a atracciones. El dueño  del Smart Contract puede:

· Crear nuevas atracciones y alimentos.

· Dar de baja atracciones y alimentos por cualquier motivo.

· Obtener el historial de cada uno de los usuarios. (Esto podria dar beneficios a usuarios con un Loyalty program)

· Aumentar el numero total de Tokens en circulacion.

Los usuarios pueden devolver los tokens que no se han utilizado por Ethers y estos tokens volveran al dueño del Smart Contract (Disney).

## Dependencias

El SmartContract DISNEY.sol necesitara la importacion de otros dos Smart Contracts llamados ERC20.sol y SafeMatch.sol para su perfecta función.
