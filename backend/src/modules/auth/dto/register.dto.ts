import { IsEmail, IsNotEmpty, IsString, MinLength, IsOptional, IsIn } from 'class-validator';

export class RegisterDto {
  @IsString()
  @IsNotEmpty({ message: "Le nom d'utilisateur est requis" })
  username: string;

  @IsEmail({}, { message: "L'email doit être valide" })
  @IsNotEmpty({ message: "L'email est requis" })
  email: string;

  @IsString()
  @MinLength(6, { message: 'Le mot de passe doit contenir au moins 6 caractères' })
  password: string;

  // CORRECTION: @IsOptional pour que le champ puisse être omis sans erreur
  // @IsIn pour valider les valeurs acceptées par le schema User
  @IsOptional()
  @IsString()
  @IsIn(['Admin', 'Pharmacien', 'Caissier'], { message: 'Rôle invalide' })
  role?: string;
}
