import { Controller, Get, Patch, Param, UseGuards } from '@nestjs/common';
import { AlertsService } from './alerts.service';
import { LotsService } from '../lots/lots.service';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';

@Controller('alerts')
@UseGuards(JwtAuthGuard, RolesGuard)
export class AlertsController {
  constructor(
    private readonly alertsService: AlertsService,
    private readonly lotsService: LotsService
  ) {}

  @Get()
  @Roles('Admin', 'Pharmacien')
  async getAlerts() {
    const alerts = await this.alertsService.findUnread();
    return { success: true, data: alerts };
  }

  @Patch(':id/read')
  @Roles('Admin', 'Pharmacien')
  async markAsRead(@Param('id') id: string) {
    const alert = await this.alertsService.markAsRead(id);
    return { success: true, data: alert, message: 'Alerte marquée comme lue' };
  }

  @Get('check-expiring')
  @Roles('Admin')
  async checkExpiringLots() {
    // CORRECTION: vérifier si une alerte non-lue existe déjà pour ce médicament
    // avant d'en créer une nouvelle (évite les doublons à chaque appel)
    const expiringLots = await this.lotsService.findExpiring(30);
    let generated = 0;
    for (const lot of expiringLots) {
      const alreadyExists = await this.alertsService.existsUnread(
        'expiration',
        lot.medicine as any
      );
      if (!alreadyExists) {
        await this.alertsService.create({
          type: 'expiration',
          medicine: lot.medicine as any,
          valeur: `Le lot ${lot.numeroLot} expire le ${lot.dateExpiration.toLocaleDateString('fr-FR')}`,
        });
        generated++;
      }
    }
    return { success: true, generated };
  }
}
