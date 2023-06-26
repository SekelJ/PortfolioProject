/*

Cleaning Data in SQL Queries

*/

SELECT *
FROM Portfolio..NashvilleHousing

-------------------------------------------------------------------------

--Standardize Date Format


SELECT SaleDateConverted, CONVERT(date, SaleDate)
FROM Portfolio..NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(date, SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(date, SaleDate)

-------------------------------------------------------------------------

--Populate Property Address Data


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Portfolio..NashvilleHousing a
JOIN Portfolio..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Portfolio..NashvilleHousing a
JOIN Portfolio..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

-------------------------------------------------------------------------

--Breaking out Address into Individual Columns (Address, City, State)


SELECT PropertyAddress
FROM Portfolio..NashvilleHousing
--WHERE PropertyAddress is null
--ORDER BY ParcelID

-- '-1' is before comma appears '+1' is after comma appears
-- SUBSTRING(String, Starting Point (1 is first), Length - CharINDEX('Character', Column) so length goes to this specified character and charindex makes it a number. +1 and -1 will set it behind or in front of the desired position
-- LEN(PropertyAddress) gives the number of characters to get to the end of the string
SELECT 
SUBSTRING(PropertyAddress, 1,CHARINDEX(',', PropertyAddress) - 1) AS Street
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS City

FROM Portfolio..NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertyStreet NVarChar(255);

UPDATE NashvilleHousing
SET PropertyStreet = SUBSTRING(PropertyAddress, 1,CHARINDEX(',', PropertyAddress) - 1)

ALTER TABLE NashvilleHousing
Add PropertyCity NVarChar(255);

UPDATE NashvilleHousing
SET PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

SELECT *
FROM Portfolio..NashvilleHousing



SELECT OwnerAddress
FROM Portfolio..NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)
FROM Portfolio..NashvilleHousing


ALTER TABLE NashvilleHousing
Add OwnerSplitAddress NVarChar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity NVarChar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState NVarChar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)

SELECT * 
FROM Portfolio..NashvilleHousing



-------------------------------------------------------------------------

--Change Y and N to Yes and No in "Sold as Vacant" Field

SELECT DISTINCT(SoldAsVacant) , COUNT(SoldAsVacant)
FROM Portfolio..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2



SELECT SoldAsVacant
,	CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
		WHEN SoldAsVacant = 'N' THEN 'NO'
		ELSE SoldAsVacant
		END
FROM Portfolio..NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
		WHEN SoldAsVacant = 'N' THEN 'NO'
		ELSE SoldAsVacant
		END

-------------------------------------------------------------------------

--Remove Duplicates


WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

FROM Portfolio..NashvilleHousing
--ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1 


-------------------------------------------------------------------------

--Delete Unused Columns


SELECT * 
FROM Portfolio..NashvilleHousing


ALTER TABLE Portfolio..NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict

ALTER TABLE Portfolio..NashvilleHousing
DROP COLUMN SaleDate


