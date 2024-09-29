// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EnergyCertification {

    address public owner;
    
    // Structure to represent a product certification
    struct Certification {
        string productName;
        string productModel;
        string energyRating;
        string certificationDocument;
        string issuingAuthority;
        uint256 validUntil;  // Timestamp until when the certification is valid
    }

    // List to keep track of approved certificate issuers
    mapping(address => bool) public certificateIssuers;
    
    // Mapping to store energy certifications for products (identified by product ID)
    mapping(bytes32 => Certification) public productCertifications;

    // Modifier to restrict certain functions to only the owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action.");
        _;
    }

    // Modifier to restrict certain functions to approved certificate issuers
    modifier onlyIssuer() {
        require(certificateIssuers[msg.sender] == true, "Only an approved certificate issuer can perform this action.");
        _;
    }

    // Event to notify when a certificate issuer is added or removed
    event CertificateIssuerUpdated(address indexed issuer, bool approved);

    // Event to notify when a product is certified
    event ProductCertified(
        bytes32 indexed productId,
        string productName,
        string productModel,
        string energyRating,
        string certificationDocument,
        string issuingAuthority,
        uint256 validUntil
    );

    constructor() {
        owner = msg.sender;
    }

    // Function to add or remove a certificate issuer, only accessible by the owner
    function updateCertificateIssuer(address _issuer, bool _approved) public onlyOwner {
        certificateIssuers[_issuer] = _approved;
        emit CertificateIssuerUpdated(_issuer, _approved);
    }

    // Function for certificate issuers to issue a certification to a product
    function certifyProduct(
        bytes32 _productId,
        string memory _productName,
        string memory _productModel,
        string memory _energyRating,
        string memory _certificationDocument,
        string memory _issuingAuthority,
        uint256 _validityPeriod
    ) public onlyIssuer {
        uint256 validUntil = block.timestamp + _validityPeriod;
        productCertifications[_productId] = Certification(
            _productName,
            _productModel,
            _energyRating,
            _certificationDocument,
            _issuingAuthority,
            validUntil
        );
        emit ProductCertified(_productId, _productName, _productModel, _energyRating, _certificationDocument, _issuingAuthority, validUntil);
    }

    // Function for the owner to transfer ownership
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "New owner cannot be the zero address.");
        owner = newOwner;
    }

    // Function to retrieve the certification details of a product
    function getProductCertification(bytes32 _productId) public view returns (
        string memory productName,
        string memory productModel,
        string memory energyRating,
        string memory certificationDocument,
        string memory issuingAuthority,
        uint256 validUntil
    ) {
        Certification memory certification = productCertifications[_productId];
        return (
            certification.productName,
            certification.productModel,
            certification.energyRating,
            certification.certificationDocument,
            certification.issuingAuthority,
            certification.validUntil
        );
    }

    // Function to check if a product's certification is still valid
    function isProductCertificationValid(bytes32 _productId) public view returns (bool) {
        Certification memory certification = productCertifications[_productId];
        return block.timestamp <= certification.validUntil;
    }
}
