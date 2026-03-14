import { IsString, IsNumber, IsOptional, IsNotEmpty, IsDateString } from 'class-validator';

export class CreateMedicineDto {
  @IsString()
  @IsNotEmpty()
  name: string;

  @IsString()
  @IsOptional()
  category?: string;

  @IsString()
  @IsOptional()
  codeBarre?: string;

  @IsString()
  @IsOptional()
  fournisseur?: string;

  @IsNumber()
  @IsOptional()
  price?: number;

  @IsNumber()
  @IsOptional()
  min_threshold?: number;

  @IsNumber()
  @IsOptional()
  stock_quantity?: number;

  @IsDateString()
  @IsOptional()
  expiry_date?: string;

  @IsNumber()
  @IsOptional()
  buying_price?: number;
}
