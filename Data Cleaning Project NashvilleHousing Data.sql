--- Data cleaning project in SQL. Data from a public data set, NashvilleHousing, was used for cleaning. 

SELECT * 
FROM [SQL Portfolio project].dbo.NashvilleHousing

--Standardize Date Format

SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM [SQL Portfolio project].dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date; 

Update NashvilleHousing
SET SaleDateConverted = CONVERT (Date, SaleDate) 

-- Populate Property Address
-- Using ParcelID to autopopulate any missing propery addresses. This required the table to be joined to itself. 

SELECT PropertyAddress
FROM [SQL Portfolio project].dbo.NashvilleHousing
--WHERE PropertyAddress is null 
Order by ParcelID

-- Self Joining table
---For simplicity the aliases used were a and b 

SELECT * 
FROM [SQL Portfolio project].dbo.NashvilleHousing a
JOIN [SQL Portfolio project].dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID] 

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [SQL Portfolio project].dbo.NashvilleHousing a
JOIN [SQL Portfolio project].dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID] 
WHERE a.PropertyAddress is null 

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [SQL Portfolio project].dbo.NashvilleHousing a
JOIN [SQL Portfolio project].dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID] 
	WHERE a.PropertyAddress is null 

-- Breaking out Address into Individual Columns (Address, city, state) 
---- Using a substring and character index 

SELECT
SUBSTRING (PropertyAddress, 1, CHARINDEX (',', PropertyAddress)-1) AS Address 
, SUBSTRING (PropertyAddress, CHARINDEX (',', PropertyAddress)+1, LEN(PropertyAddress)) AS Address 
FROM [SQL Portfolio project].dbo.NashvilleHousing 


ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar (255); 

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX (',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar (255); 

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX (',', PropertyAddress)+1, LEN(PropertyAddress))


Select  OwnerAddress
FROM [SQL Portfolio project].dbo.NashvilleHousing 

SELECT 
PARSENAME (REPLACE(OwnerAddress,',','.'), 3)
,PARSENAME (REPLACE(OwnerAddress,',','.'), 2)
,PARSENAME (REPLACE(OwnerAddress,',','.'), 1)
FROM [SQL Portfolio project].dbo.NashvilleHousing 


ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar (255); 

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME (REPLACE(OwnerAddress,',','.'), 3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar (255); 

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME (REPLACE(OwnerAddress,',','.'), 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar (255); 


Update NashvilleHousing
SET OwnerSplitCity = PARSENAME (REPLACE(OwnerAddress,',','.'), 1)


--Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT (SoldAsVacant)
FROM [SQL Portfolio project].dbo.NashvilleHousing 
GROUP BY SoldAsVacant
order by 2


SELECT SoldAsVacant, 
	CASE When SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No' 
	ELSE SoldAsVacant
	END
FROM [SQL Portfolio project].dbo.NashvilleHousing 

Update [SQL Portfolio project].dbo.NashvilleHousing 
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No' 
	ELSE SoldAsVacant
	END

-- Remove Duplicates 
---- Using a CTE

WITH RowNumCTE AS (
Select *,
	ROW_NUMBER () OVER (
	PARTITION BY ParcelID, 
			PropertyAddress, 
			SalePrice, 
			SaleDate, 
			LegalReference 
			ORDER BY
				UniqueID
				) row_num
FROM [SQL Portfolio project].dbo.NashvilleHousing 
)

SELECT *
FROM RowNumCTE
WHERE Row_num > 1 


--- DELETE UNUSED COLUMNS

SELECT *
FROM [SQL Portfolio project].dbo.NashvilleHousing  

ALTER TABLE [SQL Portfolio project].dbo.NashvilleHousing  
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE [SQL Portfolio project].dbo.NashvilleHousing  
DROP COLUMN SaleDate

--- This concludes the data cleaning project. Thank you for reading. 