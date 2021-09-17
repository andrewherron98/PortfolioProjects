-- Cleansing data in SQL

SELECT *
FROM PortfolioProject..NashvilleHousing

--Standard Date Format
SELECT SaleDateConverted
FROM PortfolioProject..NashvilleHousing

UPDATE PortfolioProject..NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE PortfolioProject..NashvilleHousing
ADD SaleDateConverted Date;

UPDATE PortfolioProject..NashvilleHousing
SET SaleDateConverted = Convert(Date,SaleDate)

--Populate Property Address Data
SELECT *
FROM PortfolioProject..NashvilleHousing
--WHERE PropertyAddress is null
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is Null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]

--Breaking out Address into Individual Columns (Address, City , State)
SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing


SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as City
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
ADD PropertySplitAddress nvarchar(255);

UPDATE PortfolioProject..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE PortfolioProject..NashvilleHousing
ADD PropertySplitCity nvarchar(255);

UPDATE PortfolioProject..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

--Checking the UPDATE
SELECT PropertySplitCity,PropertySplitAddress
From PortfolioProject..NashvilleHousing

--Split Owner Address
SELECT
SUBSTRING(OwnerAddress,1,CHARINDEX(',',OwnerAddress)-1) as OwnerSplitAddress
From PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitAddress = SUBSTRING(OwnerAddress,1,CHARINDEX(',',OwnerAddress)-1)

SELECT OwnerAddress,
SUBSTRING(OwnerAddress,LEN(OwnerAddress)-1, 2) as OwnerSplitState
,SUBSTRING(OwnerAddress,CHARINDEX(',',OwnerAddress),LEN(OwnerAddress)) as OwnerCityState
From PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitState nvarchar(255);

ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerCityState nvarchar(255);

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitState = SUBSTRING(OwnerAddress,LEN(OwnerAddress)-1, 2)

UPDATE PortfolioProject..NashvilleHousing
SET OwnerCityState = SUBSTRING(OwnerAddress,CHARINDEX(',',OwnerAddress)+2,LEN(OwnerAddress))

SELECT
SUBSTRING(OwnerCityState,1, CHARINDEX(',',OwnerCityState)-1) as OwnerSplitCity
From PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitCity nvarchar(255);

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitCity = SUBSTRING(OwnerCityState,1, CHARINDEX(',',OwnerCityState)-1)

--Change Y and N in 'Sold As Vacant'
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM PortfolioProject..NashvilleHousing

UPDATE PortfolioProject..NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END

--Remove Duplicates

WITH RowNumCTE AS(
SELECT*,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num

FROM PortfolioProject..NashvilleHousing
--ORDER BY ParcelID
)

SELECT*
FROM RowNumCTE
WHERE Row_num >1


--Delete Unused Columns
SELECT*
FROM PortfolioProject..NashvilleHousing


ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerCityState, OwnerAddress,PropertyAddress